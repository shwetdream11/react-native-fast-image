package com.dylanvann.fastimage;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.PorterDuffXfermode;
import android.graphics.Shader;
import android.graphics.drawable.BitmapDrawable;

import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation;

import java.nio.charset.Charset;
import java.security.MessageDigest;

public class FastImageGradientTransformation extends BitmapTransformation {
    private static final int VERSION = 1;
    private static final String ID = "com.bumptech.glide.transformations.GradientTransformation." + VERSION;

    private FastImageGradient gradient;
    private String url;

    public FastImageGradientTransformation(FastImageGradient gradient, String url) {
        this.gradient = gradient;
        this.url = url;
    }

    @Override
    protected Bitmap transform(BitmapPool pool, Bitmap toTransform, int outWidth, int outHeight) {
        if (gradient != null) {
            return addGradient(toTransform, pool);
        }
        return toTransform;
    }

    private float[] calculateGradientLocationWithAngle(float angle) {
        float angleRad = (angle - 90.0f) * ((float)Math.PI / 180.0f);
        float length = (float)Math.sqrt(2.0);

        return new float[]{
                (float) Math.cos(angleRad) * length,
                (float) Math.sin(angleRad) * length
        };
    }

    private Bitmap addGradient(Bitmap originalBitmap, BitmapPool pool) {
        int width = originalBitmap.getWidth();
        int height = originalBitmap.getHeight();

        Bitmap updatedBitmap = pool.get(width, height, Bitmap.Config.ARGB_8888);
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

    @Override
    public boolean equals(Object o) {
        Boolean result = o instanceof FastImageGradientTransformation &&
                ((FastImageGradientTransformation) o).gradient == gradient &&
                ((FastImageGradientTransformation) o).url.equals(url);
        return result;
    }

    @Override
    public int hashCode() {
        int hash = ID.hashCode() + url.hashCode();
        if (gradient != null) {
            hash = hash ^ gradient.hashCode();
        }
        return hash;
    }

    @Override
    public void updateDiskCacheKey(MessageDigest messageDigest) {
        if (gradient != null) {
            messageDigest.update((ID + hashCode()).getBytes(Charset.forName("UTF-8")));
        }
    }
}
