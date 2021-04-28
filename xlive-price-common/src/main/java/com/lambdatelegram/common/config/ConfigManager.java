package com.lambdatelegram.common.config;


import java.util.MissingResourceException;
import java.util.ResourceBundle;

import static java.lang.System.getenv;

public class ConfigManager {

    private ConfigManager() {
    }

    public static String getAppProperty(String name) {
        return ResourceBundle.getBundle("app").getString(name);
    }

    public static String getEnvVar(String name) {
        String value = getenv(name);
        if (value == null || value.isEmpty()) {
            throw new MissingResourceException(String.format("Can't find resource %s. Please set Lambda env variable", name), name, name);
        }
        return value;
    }
}
