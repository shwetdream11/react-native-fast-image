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
    public GlideUrl glideUrl;
    public @Nullable FastImageGradient gradient;

    public FastImageViewWithUrl(Context context) {
        super(context);
    }

    @Override
    public void setImageDrawable(@Nullable Drawable drawable) {
        if (drawable != null && gradient != null && (drawable instanceof BitmapDrawable)) {
            Bitmap gradientBitmap = addGradient(((BitmapDrawable) drawable).getBitmap());
            BitmapDrawable gradientDrawable = new BitmapDrawable(getResources(), gradientBitmap);
            super.setImageDrawable(gradientDrawable);
        } else {
            super.setImageDrawable(drawable);
        }
    }

    Bitmap addGradient(Bitmap originalBitmap) {
        int width = originalBitmap.getWidth();
        int height = originalBitmap.getHeight();
        Bitmap updatedBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(updatedBitmap);

        canvas.drawBitmap(originalBitmap, 0, 0, null);
        Paint paint = new Paint();
        LinearGradient shader = new LinearGradient(0, 0, width, height, gradient.mColors, gradient.mLocations, Shader.TileMode.CLAMP);
        paint.setShader(shader);
        paint.setXfermode(new PorterDuffXfermode(gradient.mBlendMode));
        canvas.drawRect(0, 0, width, height, paint);

        return updatedBitmap;
    }
}
