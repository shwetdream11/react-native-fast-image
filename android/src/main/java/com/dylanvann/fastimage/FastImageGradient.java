package com.dylanvann.fastimage;

import android.content.Context;
import android.graphics.PorterDuff;

public class FastImageGradient {
    public PorterDuff.Mode mBlendMode;
    public int[] mColors;
    public float[] mLocations;

    public FastImageGradient(Context context, int[] colors, PorterDuff.Mode blendMode, float[] locations) {
        super();
        mColors = colors;
        mBlendMode = blendMode;
        mLocations = locations;
    }
}
