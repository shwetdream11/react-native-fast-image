package com.dylanvann.fastimage;

public enum BlendModeQuality {
    HIGH("HIGH"),
    MEDIUM("MEDIUM"),
    LOW("LOW"),
    NONE("NONE");
    public final String value;

    BlendModeQuality(String quality) {
        this.value = quality;
    }
}
