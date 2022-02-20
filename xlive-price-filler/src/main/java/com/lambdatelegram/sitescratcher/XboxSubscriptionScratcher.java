package com.lambdatelegram.sitescratcher;


import com.lambdatelegram.common.enums.Subscriptions;
import com.lambdatelegram.common.models.XboxSubscriptionPrice;
import okhttp3.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static com.lambdatelegram.common.enums.Subscriptions.*;


public class XboxSubscriptionScratcher {
    private static final Log logger = LogFactory.getLog(XboxSubscriptionScratcher.class);
    private static final String URL = "https://www.xbox-now.com/en/xbox-live-gold-comparison?page=";
    private static final String URL_PASS = "https://www.xbox-now.com/en/game-pass-comparison?page=";
    private static final String URL_ULTIMATE_PASS = "https://www.xbox-now.com/en/game-pass-ultimate-comparison?page=";
    private static final String URL_EA = "https://www.xbox-now.com/en/ea-access-comparison?page=";
    private static final Pattern PASS_PATTERN = Pattern.compile("<span.*\">(.*)GBP</span>.*\">(.*)GBP</span>");
    private static final OkHttpClient client = new OkHttpClient();

    private static String run(String url) throws IOException {
        StringBuilder responseBody = new StringBuilder();
        for (int i = 1; i < 4; i++) {
            Request request = new Request.Builder()
                    .url(url + i)
                    .header("User-Agent", "Mozilla/5.0 (Linux; U; Android 2.2) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1")
                    .build();
            logger.info(request);
            Response response = client.newCall(request).execute();
            responseBody.append(response.body().string().trim()
                    .replace(" ", "")
                    .replace("\n", "")
                    .replace("\t", "")
                    .replace("\r", ""));
        }
        //logger.info(responseBody.toString());
        return responseBody.toString();
    }

    public static List<XboxSubscriptionPrice> extractGoldPrice() throws IOException {
        String out = run(URL);
        logger.info("start looking for gold");
        Matcher matcher = Pattern.compile("OriginalPrice:([0-9]+.[0-9]+)GBP.*OriginalPrice:(.*)GBP").matcher(out);
        List<Subscriptions> goldList = Arrays.asList(GOLD_MONTH, GOLD_THREE);
        if (matcher.find()) {
            logger.info("matched");
            logger.info(String.format("GOLD MONTH: %s", matcher.group(GOLD_MONTH.getRegExpGroup())));
            logger.info(String.format("GOLD 3 MONTHS: %s", matcher.group(GOLD_THREE.getRegExpGroup())));
            return goldList.stream()
                    .map(frequency -> new XboxSubscriptionPrice()
                            .setSubscription(frequency)
                            .setPrice(Double.valueOf(matcher.group(frequency.getRegExpGroup()).trim())))
                    .collect(Collectors.toList());
        }
        logger.info("price not found");
        return goldList.stream()
                .map(subscription -> new XboxSubscriptionPrice().setPrice(0.0).setSubscription(subscription))
                .collect(Collectors.toList());
    }

    public static List<XboxSubscriptionPrice> extractEaAccessPrice() throws IOException {
        logger.info("start looking for ea access");
        String out = run(URL_EA);
        Pattern p = Pattern.compile("<span.*\">(.*)GBP</span>.*\">(.*)GBP</span>");
        Matcher matcher = p.matcher(out);
        List<Subscriptions> goldList = Arrays.asList(EA_ACCESS_MONTH, EA_ACCESS_YEAR);
        if (matcher.find()) {
            return goldList.stream()
                    .map(frequency -> new XboxSubscriptionPrice()
                            .setSubscription(frequency)
                            .setPrice(Double.valueOf(matcher.group(frequency.getRegExpGroup()).trim())))
                    .collect(Collectors.toList());
        }
        logger.info("price not found");
        return goldList.stream()
                .map(subscription -> new XboxSubscriptionPrice().setPrice(0.0).setSubscription(subscription))
                .collect(Collectors.toList());
    }

    public static XboxSubscriptionPrice extractGameUltimatePrice() throws IOException {
        return extractSubscriptionPrice(ULTIMATE, URL_ULTIMATE_PASS);
    }

    public static XboxSubscriptionPrice extractGamePassPrice() throws IOException {
        return extractSubscriptionPrice(Subscriptions.GAME_PASS, URL_PASS);
    }

    private static XboxSubscriptionPrice extractSubscriptionPrice(Subscriptions subscription, String url) throws IOException {
        String out = run(url);
        logger.info("start looking for " + subscription.getDBColumnName());
        Matcher matcher = PASS_PATTERN.matcher(out);
        if (matcher.find()) {
            XboxSubscriptionPrice price = new XboxSubscriptionPrice()
                    .setSubscription(subscription)
                    .setPrice(Double.valueOf(matcher.group(1).trim())); // group 2 for New Customers. Will be implement later
            logger.info(String.format("Price found %s", price.getPrice()));
            return price;
        }
        logger.info("price not found");
        return new XboxSubscriptionPrice().setPrice(0.0).setSubscription(subscription);
    }

    public String mapToString(Map<String, String> map) {
        return map.keySet().stream()
                .map(key -> key + "=" + map.get(key))
                .collect(Collectors.joining(", \n"));
    }

}
