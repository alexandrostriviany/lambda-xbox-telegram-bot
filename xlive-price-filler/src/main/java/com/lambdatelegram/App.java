package com.lambdatelegram;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.lambdatelegram.common.DynamoDbProvider;
import com.lambdatelegram.common.enums.Subscriptions;
import com.lambdatelegram.common.models.XboxSubscriptionPrice;
import okhttp3.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.EnumMap;
import java.util.List;

import static com.lambdatelegram.common.config.ConfigManager.getEnvVar;
import static com.lambdatelegram.common.enums.Subscriptions.*;
import static com.lambdatelegram.common.utils.Emoji.SMALL_RED_TRIANGLE;
import static com.lambdatelegram.common.utils.Emoji.SMALL_RED_TRIANGLE_DOWN;
import static com.lambdatelegram.sitescratcher.XboxSubscriptionScratcher.*;
import static org.apache.http.entity.ContentType.APPLICATION_JSON;

public class App implements RequestStreamHandler {
    private static final Log log = LogFactory.getLog(App.class);
    DynamoDbProvider dbProvider =
            new DynamoDbProvider(getEnvVar("REGION"), getEnvVar("PRICE_TABLE"));
    private static final OkHttpClient client = new OkHttpClient();


    @Override
    public void handleRequest(InputStream input, OutputStream output, Context context) throws IOException {
        try {
            handleUpdate();
        } catch (Exception e) {
            log.error("Failed to handle update: " + e);
            throw new IOException("Failed to handle update!", e);
        }
    }

    private void handleUpdate() throws IOException {
        List<XboxSubscriptionPrice> golds = extractGoldPrice();
        List<XboxSubscriptionPrice> ea = extractEaAccessPrice();
        EnumMap<Subscriptions, XboxSubscriptionPrice> subscriptionsList = new EnumMap<>(Subscriptions.class);
        subscriptionsList.put(GOLD_MONTH, golds.get(0));
        subscriptionsList.put(GOLD_THREE, golds.get(1));
        subscriptionsList.put(ULTIMATE, extractGameUltimatePrice());
        subscriptionsList.put(GAME_PASS, extractGamePassPrice());
        subscriptionsList.put(EA_ACCESS_MONTH, ea.get(0));
        subscriptionsList.put(EA_ACCESS_YEAR, ea.get(1));

        subscriptionsList.keySet().forEach(subscription -> {
                    String date = new SimpleDateFormat("dd MMMM yyyy").format(new Date());
                    XboxSubscriptionPrice newSPrice = subscriptionsList.get(subscription);
                    Double newPrice = newSPrice.getPrice();
                    Double oldPrice = dbProvider.getPriceBySubscriptionName(subscription).getPrice();
                    //POST to lambda GW if price changed
                    checkPriceIsChanged(subscriptionsList, subscription, date, newSPrice, newPrice, oldPrice);
                }
        );
        log.info(subscriptionsList.values());
    }

    private void checkPriceIsChanged(EnumMap<Subscriptions, XboxSubscriptionPrice> subscriptionsList,
                                     Subscriptions subscription, String date, XboxSubscriptionPrice newSPrice,
                                     Double newPrice, Double oldPrice) {
        try {
            if (!newPrice.equals(oldPrice)) {
                newSPrice.setLastUpdate(date);
                dbProvider.updatePrice(newSPrice);
                if (newPrice > oldPrice) {
                    postUpdateMessage(SMALL_RED_TRIANGLE + " Price UP " + subscriptionsList.get(subscription).toFormattedPriceAsString());
                    log.info(SMALL_RED_TRIANGLE + " Price UP " + subscriptionsList.get(subscription).toFormattedPriceAsString());
                } else {
                    postUpdateMessage(SMALL_RED_TRIANGLE_DOWN + " Price DOWN " + subscriptionsList.get(subscription).toFormattedPriceAsString());
                    log.info(SMALL_RED_TRIANGLE_DOWN + " Price DOWN " + subscriptionsList.get(subscription).toFormattedPriceAsString());
                }
                subscriptionsList.remove(subscription);
            }
        } catch (IOException e) {
            log.info("error");
        }
    }

    String postUpdateMessage(String message) throws IOException {
        String chatId = getEnvVar("XLIVE_PRICE_FILLER_CHAT_ID");
        String botUrl = getEnvVar("BOT_URL");
        String updateJson = String.format("{\"message\":{\"chat\":{\"id\":\"%s\"},\"text\":\"%s\"}}", chatId, message);
        RequestBody body = RequestBody.create(MediaType.parse(APPLICATION_JSON.getMimeType()), updateJson);
        Request request = new Request.Builder()
                .url(botUrl)
                .post(body)
                .build();
        Response response = client.newCall(request).execute();
        return response.body().string();
    }
}
