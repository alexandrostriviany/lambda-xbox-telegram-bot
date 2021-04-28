package com.lambdatelegram.common;

import com.amazonaws.regions.Regions;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.amazonaws.services.dynamodbv2.document.Item;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.lambdatelegram.common.enums.Subscriptions;
import com.lambdatelegram.common.models.XboxSubscriptionPrice;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.Optional;


public class DynamoDbProvider {
    private static final Log logger = LogFactory.getLog(DynamoDbProvider.class);
    private static final String NAME = "NAME";
    private static final String PRICE = "PRICE";
    private static final String DATE = "DATE";

    AmazonDynamoDB client;
    DynamoDB dynamoDB;
    Table table;

    public DynamoDbProvider(String region, String tableName){
        client = AmazonDynamoDBClientBuilder.standard().withRegion(region).build();
        dynamoDB = new DynamoDB(client);
        table = dynamoDB.getTable(tableName);
    }

    public XboxSubscriptionPrice getPriceBySubscriptionName(Subscriptions subscription) {
        double price = 0;
        String date = "never";
        String name = subscription.getDBColumnName();
        try {
            Item item = table.getItem(NAME, name);
            date = (String) item.get(DATE);
            price = parseDouble((String) item.get(PRICE)).orElse(price);
        } catch (Exception e) {
            logger.error(e.getMessage());
        }
        logger.info(String.format("Price selected. NAME:%s PRICE:%s DATE:%s", subscription.getDBColumnName(), price, date));
        return new XboxSubscriptionPrice().setPrice(price).setSubscription(subscription).setLastUpdate(date);
    }


    public void updatePrice(XboxSubscriptionPrice subscriptionPrice) {
        try {
            table.putItem(new Item()
                    .withPrimaryKey(NAME, subscriptionPrice.getSubscription().getDBColumnName())
                    .withString(DATE, subscriptionPrice.getLastUpdate())
                    .withString(PRICE, subscriptionPrice.getPrice().toString()));
            logger.info(String.format("Price changed. NAME:%s PRICE:%s DATE:%s",
                    subscriptionPrice.getSubscription().getDBColumnName(),
                    subscriptionPrice.getPrice(),
                    subscriptionPrice.getLastUpdate()));
        } catch (Exception e) {
            logger.error(e.getMessage());
        }
    }

    private Optional<Double> parseDouble(String input) {
        if (input == null || input.trim().length() == 0) {
            logger.error("String value is empty");
            return Optional.empty();
        }
        try {
            return Optional.of(Double.parseDouble(input));
        } catch (NumberFormatException e) {
            logger.error("Number Format Exception: " + e.getMessage());
            return Optional.empty();
        }
    }
}
