package com.dylanvann.fastimage;

public enum Memory {
    FULL(25),
    MEDIUM(15),
    LOW(5);
    int THRESHOLD_PERCENTAGE = 0;

    Memory(int threshold) {
        THRESHOLD_PERCENTAGE = threshold;
    }
}
