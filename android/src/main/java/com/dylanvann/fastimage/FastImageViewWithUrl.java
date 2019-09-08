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

import com.bumptech.glide.load.model.GlideUrl;

class FastImageViewWithUrl extends ImageView {
    private GlideUrl glideUrl;
    private @Nullable FastImageGradient gradient;
    private BlendModeQuality blendModeQuality;

    public FastImageViewWithUrl(Context context) {
        super(context);
        blendModeQuality = BlendModeQuality.NONE;
    }

    @Override
    public void setImageDrawable(@Nullable Drawable drawable) {
        Memory memory = Utils.getMemoryAvailablity();
        setBlendModeQuality(memory);
        if (gradient != null && (drawable instanceof BitmapDrawable) && memory != Memory.LOW) {
            Bitmap gradientBitmap = addGradient(((BitmapDrawable) drawable).getBitmap(), memory);
            BitmapDrawable gradientDrawable = new BitmapDrawable(getResources(), gradientBitmap);
            super.setImageDrawable(gradientDrawable);
        } else {
            super.setImageDrawable(drawable);
        }
    }

    private float[] calculateGradientLocationWithAngle(float angle) {
        float angleRad = (angle - 90.0f) * ((float) Math.PI / 180.0f);
        float length = (float) Math.sqrt(2.0);

        return new float[]{
                (float) Math.cos(angleRad) * length,
                (float) Math.sin(angleRad) * length
        };
    }

    public GlideUrl getGlideUrl() {
        return glideUrl;
    }

    public void setGlideUrl(GlideUrl glideUrl) {
        this.glideUrl = glideUrl;
    }

    @Nullable
    public FastImageGradient getGradient() {
        return gradient;
    }

    public void setGradient(@Nullable FastImageGradient gradient) {
        this.gradient = gradient;
    }

    private void setBlendModeQuality(Memory memory) {
        if (gradient != null) {
            switch (memory) {
                case FULL:
                    blendModeQuality = BlendModeQuality.HIGH;
                    break;
                case MEDIUM:
                    blendModeQuality = BlendModeQuality.MEDIUM;
                    break;
                case LOW:
                    blendModeQuality = BlendModeQuality.LOW;
                    break;
            }
        }
    }

    public BlendModeQuality getBlendModeQuality() {
        return blendModeQuality;
    }

    Bitmap addGradient(Bitmap originalBitmap, Memory memory) {
        int width = originalBitmap.getWidth();
        int height = originalBitmap.getHeight();
        Bitmap updatedBitmap = Bitmap.createBitmap(width, height, memory == Memory.FULL ? Bitmap.Config.ARGB_8888 : Bitmap.Config.ARGB_4444);
        Canvas canvas = new Canvas(updatedBitmap);

        canvas.drawBitmap(originalBitmap, 0, 0, null);
        Paint paint = new Paint();

        float[] startPos = {0, 0};
        float[] endPos = {1, 1};
        float[] mAngleCenter = {0.5f, 0.5f};

        if (gradient.mAngle != 0) {
            float[] angleSize = calculateGradientLocationWithAngle(gradient.mAngle);
            startPos = new float[]{
                    mAngleCenter[0] - angleSize[0] / 2.0f,
                    mAngleCenter[1] - angleSize[1] / 2.0f
            };
            endPos = new float[]{
                    mAngleCenter[0] + angleSize[0] / 2.0f,
                    mAngleCenter[1] + angleSize[1] / 2.0f
            };
        }

        LinearGradient shader = new LinearGradient(startPos[0] * width, startPos[1] * height, endPos[0] * width, endPos[1] * height, gradient.mColors, gradient.mLocations, Shader.TileMode.CLAMP);
        paint.setShader(shader);
        paint.setXfermode(new PorterDuffXfermode(gradient.mBlendMode));
        canvas.drawRect(0, 0, width, height, paint);
        return updatedBitmap;
    }
}
