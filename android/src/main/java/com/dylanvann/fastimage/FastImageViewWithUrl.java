package com.dylanvann.fastimage;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.PorterDuffXfermode;
import android.graphics.Shader;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.support.annotation.Nullable;
import android.widget.ImageView;

import com.bumptech.glide.RequestManager;
import com.bumptech.glide.load.model.GlideUrl;

class FastImageViewWithUrl extends ImageView {
    private GlideUrl glideUrl;
    private @Nullable FastImageGradient gradient;

    public FastImageViewWithUrl(Context context) {
        super(context);
    }

    public GlideUrl getGlideUrl() {
        return glideUrl;
    }

    public void setGlideUrl(GlideUrl glideUrl) {
        this.glideUrl = glideUrl;
    }

    public FastImageGradient getGradient() { return gradient; }

    public void setGradient(FastImageGradient gradient) { this.gradient = gradient; }
}
