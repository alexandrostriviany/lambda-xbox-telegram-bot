package com.lambdatelegram.common.enums;

public enum Subscriptions {
    GOLD_MONTH("gold_1", 3, "./logo/gold.jpg", 2),
    GOLD_THREE("gold_3", 4, "./logo/gold.jpg", 1),
    GOLD_YEAR("gold_12", 5, "./logo/gold.jpg", 0), // deprecated
    ULTIMATE("ultimate", 1, "./logo/ultimate.jpg", 1),
    GAME_PASS("game_pass", 2, "./logo/pass.jpg", 1),
    EA_ACCESS_MONTH("ea_access_1", 6, "./logo/eaaccess.jpg", 1),
    EA_ACCESS_YEAR("ea_access_12", 7, "./logo/eaaccess.jpg", 2);

    private final String dbColumnName;
    private final String logoPath;
    private final int sortingValue;
    private final int regExpGroup;

    Subscriptions(String dbColumnName, int sortingValue, String logoPath, int regExpGroup) {
        this.dbColumnName = dbColumnName;
        this.sortingValue = sortingValue;
        this.logoPath = logoPath;
        this.regExpGroup = regExpGroup;
    }

    public String getDBColumnName() {
        return dbColumnName;
    }

    public String getLogoPath() {
        return logoPath;
    }

    public int getSortingValue() {
        return sortingValue;
    }

    public int getRegExpGroup() {
        return regExpGroup;
    }
}
