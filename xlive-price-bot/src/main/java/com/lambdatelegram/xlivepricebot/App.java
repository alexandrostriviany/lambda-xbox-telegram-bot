package com.lambdatelegram.xlivepricebot;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lambdatelegram.common.DynamoDbProvider;
import com.lambdatelegram.common.enums.Subscriptions;
import com.lambdatelegram.common.models.XboxSubscriptionPrice;
import org.apache.commons.io.IOUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.telegram.telegrambots.meta.api.methods.send.SendPhoto;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.ReplyKeyboardMarkup;
import org.telegram.telegrambots.meta.api.objects.replykeyboard.buttons.KeyboardRow;
import org.telegram.telegrambots.meta.bots.AbsSender;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static com.lambdatelegram.TelegramFactory.sender;
import static com.lambdatelegram.common.config.ConfigManager.getAppProperty;
import static com.lambdatelegram.common.config.ConfigManager.getEnvVar;
import static com.lambdatelegram.common.enums.Subscriptions.*;
import static com.lambdatelegram.common.utils.Emoji.ALIEN_EMOJI;
import static java.util.Arrays.asList;

public class App implements RequestStreamHandler {
    private static final Log log = LogFactory.getLog(App.class);
    private final DynamoDbProvider priceStorage =
            new DynamoDbProvider(getEnvVar("REGION"), getEnvVar("PRICE_TABLE"));
    private static final String DEFAULT_LOGO_PATH = "./logo/default.jpg";
    private static final String UPDATED_LOGO_PATH = "./logo/updated.jpg";
    private static final String LAST_TIME_WAS_CHANGED = "\n _last time was changed: ";
    private static final ObjectMapper MAPPER = new ObjectMapper();
    private static final AbsSender SENDER = sender(getEnvVar("bot_token"), getEnvVar("bot_username"));

    private static final String LIVE_GOLD_MESSAGE = "LIVE GOLD";
    private static final String GAME_PASS_MESSAGE = "GAME PASS";
    private static final String ULTIMATE_MESSAGE = "ULTIMATE";
    private static final String EA_ACCESS_MESSAGE = "EA ACCESS";
    private static final String SUBSCRIPTIONS_LIST_MESSAGE = "SUBSCRIPTIONS LIST";

    public App() {
        log.info("We are running");
    }

    @Override
    public void handleRequest(InputStream input, OutputStream output, Context context) throws IOException {
        Update update;
        try {
            String message = IOUtils.toString(input);
            log.info("Get update message \n" + message);
            update = MAPPER.readValue(message, Update.class);
        } catch (Exception e) {
            log.error("Failed to parse update: " + e);
            throw new IOException("Failed to parse update!", e);
        }
        log.info("Starting handling update" + update.toString());
        try {
            handleUpdate(update);
        } catch (Exception e) {
            log.error("Failed to handle update: " + e);
            throw new IOException("Failed to handle update!", e);
        }
        log.info("Finished handling update " + update.getUpdateId());
    }

    private void handleUpdate(Update update) throws TelegramApiException {
        if (update.getMessage() == null) {
            return;
        }
        final String updateMessage = update.getMessage().getText();
        final String userId = update.getMessage().getChatId().toString();
        try {
            if (userId.equalsIgnoreCase(getEnvVar("XLIVE_PRICE_FILLER_CHAT_ID"))) {
                sendPriceChangedMessage(updateMessage, UPDATED_LOGO_PATH);
            } else {
                if (updateMessage.contains("start")) {
                    sendPricePhotoMessage(userId, "Welcome! This bot helps to keep track of changes in XBOX subscription prices and promotions.", DEFAULT_LOGO_PATH);
                    return;
                }
                if (updateMessage.contains(LIVE_GOLD_MESSAGE)) {
                    List<Subscriptions> goldList = asList(GOLD_MONTH, GOLD_THREE);
                    List<XboxSubscriptionPrice> priceList = goldList.stream()
                            .map(priceStorage::getPriceBySubscriptionName)
                            .collect(Collectors.toList());
                    String responseMessage = priceList
                            .stream()
                            .map(price -> price.toFormattedPriceAsString() + LAST_TIME_WAS_CHANGED + price.getLastUpdate() + "_ \n")
                            .collect(Collectors.joining());
                    sendPricePhotoMessage(userId, responseMessage, goldList.get(1).getLogoPath());
                    return;
                }
                if (updateMessage.contains(ULTIMATE_MESSAGE)) {
                    XboxSubscriptionPrice price = priceStorage.getPriceBySubscriptionName(ULTIMATE);
                    sendPricePhotoMessage(userId, price.toFormattedPriceAsString() + LAST_TIME_WAS_CHANGED + price.getLastUpdate() + "_ ", price.getSubscription().getLogoPath());
                    return;
                }
                if (updateMessage.contains(GAME_PASS_MESSAGE)) {
                    XboxSubscriptionPrice price = priceStorage.getPriceBySubscriptionName(GAME_PASS);
                    sendPricePhotoMessage(userId, price.toFormattedPriceAsString() + LAST_TIME_WAS_CHANGED + price.getLastUpdate() + "_ ", price.getSubscription().getLogoPath());
                    return;
                }
                if (updateMessage.contains(EA_ACCESS_MESSAGE)) {
                    List<Subscriptions> eaList = asList(EA_ACCESS_MONTH, EA_ACCESS_YEAR);
                    List<XboxSubscriptionPrice> priceList = eaList
                            .stream()
                            .map(priceStorage::getPriceBySubscriptionName)
                            .collect(Collectors.toList());
                    String message = priceList
                            .stream()
                            .map(price -> price.toFormattedPriceAsString() + LAST_TIME_WAS_CHANGED + price.getLastUpdate() + "_ \n")
                            .collect(Collectors.joining());
                    sendPricePhotoMessage(userId, message, eaList.get(1).getLogoPath());
                    return;
                }
                if (updateMessage.contains(SUBSCRIPTIONS_LIST_MESSAGE)) {
                    List<Subscriptions> allSubscriptionList =
                            asList(EA_ACCESS_MONTH, EA_ACCESS_YEAR, GAME_PASS, ULTIMATE, GOLD_MONTH, GOLD_THREE);

                    List<XboxSubscriptionPrice> priceList = allSubscriptionList
                            .stream()
                            .map(priceStorage::getPriceBySubscriptionName)
                            .collect(Collectors.toList());

                    String message = priceList
                            .stream()
                            .map(price -> price.toFormattedPriceAsString() + " \n")
                            .collect(Collectors.joining());

                    sendPricePhotoMessage(userId, "*SUBSCRIPTIONS LIST*" + ALIEN_EMOJI + "\n", message + "\n\\*_price for UK region in GBP_ ", "");
                }
            }
        } catch (Exception e) {
            log.error("Failed to send mesage: " + e);
            throw new TelegramApiException(e);
        }
    }

    public void sendPriceChangedMessage(String updatedPriceMessage, String logoPath) {
        Stream.of(getAppProperty("CHAT_LIST").split(","))
                .forEach(user -> {
                    try {
                        sendPricePhotoMessage(user, updatedPriceMessage, logoPath);
                    } catch (TelegramApiException e) {
                        e.printStackTrace();
                    }
                });
    }


    void sendPricePhotoMessage(String chatId, String header, String price, String logoPath) throws TelegramApiException {
        try {
            ClassLoader classLoader = getClass().getClassLoader();
            logoPath = logoPath.isEmpty() ? DEFAULT_LOGO_PATH : logoPath;
            File headerLogo = new File(Objects.requireNonNull(classLoader.getResource(logoPath)).getFile());
            SendPhoto message = new SendPhoto()
                    .setChatId(chatId)
                    .setPhoto(headerLogo)
                    .setCaption(header + "\n" + price)
                    .setReplyMarkup(getKeyboard())
                    .setParseMode("Markdown");

            SENDER.execute(message);
            log.info("Message sent: " + message);
        } catch (Exception e) {
            log.error("Failed to send mesage: " + e);
            throw new TelegramApiException("Failed to send message!", e);
        }
    }

    private ReplyKeyboardMarkup getKeyboard() {
        ReplyKeyboardMarkup keyboard = new ReplyKeyboardMarkup();
        KeyboardRow firstRow = new KeyboardRow();
        firstRow.add(LIVE_GOLD_MESSAGE);
        firstRow.add(GAME_PASS_MESSAGE);

        KeyboardRow secondRow = new KeyboardRow();
        secondRow.add(ULTIMATE_MESSAGE);
        secondRow.add(EA_ACCESS_MESSAGE);

        KeyboardRow thirdRow = new KeyboardRow();
        thirdRow.add(SUBSCRIPTIONS_LIST_MESSAGE);
        return keyboard.setKeyboard(asList(firstRow, secondRow, thirdRow));
    }

    void sendPricePhotoMessage(String chatId, String price, String logoPath) throws TelegramApiException {
        sendPricePhotoMessage(chatId, "", price, logoPath);
    }
}
