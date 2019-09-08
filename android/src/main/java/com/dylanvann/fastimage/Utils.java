package com.dylanvann.fastimage;

public class Utils {

    public static Memory getMemoryAvailablity() {
        long total = Runtime.getRuntime().maxMemory();
        long used = Runtime.getRuntime().totalMemory();
        float percentAvailable = 100f * (1f - ((float) used / total));
        if (percentAvailable > Memory.FULL.THRESHOLD_PERCENTAGE) {
            return Memory.FULL;
        } else if (percentAvailable > Memory.MEDIUM.THRESHOLD_PERCENTAGE) {
            return Memory.MEDIUM;
        }
        return Memory.LOW;
    }
}
