/**
 *
 */
package com.performanceactive.plugins.camera;

import android.content.Context;
import android.hardware.Camera;
import android.hardware.Camera.Size;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 */
public class CustomCameraPreview extends SurfaceView implements SurfaceHolder.Callback {

    private static final String TAG = CustomCameraPreview.class.getSimpleName();

    private final Camera camera;

    public CustomCameraPreview(Context context, Camera camera) {
        super(context);
        this.camera = camera;
        getHolder().addCallback(this);
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        try {
            // TODO: show activity indicator here, it can take almost 1 second to show the preview
            camera.setPreviewDisplay(holder);
            camera.startPreview();
        } catch (IOException e) {
            Log.d(TAG, "Error starting camera preview: " + e.getMessage());
        }
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        // nothing to do here
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        if (getHolder().getSurface() == null) {
            return;
        }
        try {
            camera.stopPreview();
        } catch (Exception e){
            // tried to stop a non-existent preview
        }

        try {
            Camera.Parameters cameraSettings = camera.getParameters();
            Size previewSize = optimimalPreviewSize(width, height);
            cameraSettings.setPreviewSize(previewSize.width, previewSize.height);
            camera.setParameters(cameraSettings);
            camera.setPreviewDisplay(holder);
            camera.setDisplayOrientation(90);
            camera.startPreview();
        } catch (Exception e){
            Log.d(TAG, "Error starting camera preview: " + e.getMessage());
        }
    }

    private Size optimimalPreviewSize(int targetWidth, int targetHeight) {
        List<Size> sizes = camera.getParameters().getSupportedPreviewSizes();
        float targetAspectRatio = (float) targetWidth / targetHeight;
        List<Size> sizesWithMatchingAspectRatios = filterByAspectRatio(targetAspectRatio, sizes);
        if (sizesWithMatchingAspectRatios.size() > 0) {
            return optimalSizeForHeight(sizesWithMatchingAspectRatios, targetHeight);
        }
        return optimalSizeForHeight(sizes, targetHeight);
    }

    private List<Size> filterByAspectRatio(float targetAspectRatio, List<Size> sizes) {
        List<Size> filteredSizes = new ArrayList<Size>();
        for (Size size : sizes) {
            // reverse the ratio calculation as we've flipped the orientation
            float aspectRatio = (float)size.height / size.width;
            if (aspectRatio == targetAspectRatio) {
                filteredSizes.add(size);
            }
        }
        return filteredSizes;
    }

    private Size optimalSizeForHeight(List<Size> sizes, int targetHeight) {
        Size optimalSize = null;
        float minimumHeightDelta = Float.MAX_VALUE;
        for (Size size : sizes) {
            if (Math.abs(size.height - targetHeight) < minimumHeightDelta) {
                optimalSize = size;
                minimumHeightDelta = Math.abs(size.height - targetHeight);
            }
        }
        return optimalSize;
    }

}
