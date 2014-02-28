
package com.performanceactive.gripcamera;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.Camera;
import android.hardware.Camera.PictureCallback;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class GripCameraActivity extends Activity {

    private static final String TAG = GripCameraActivity.class.getSimpleName();

    public static String FILENAME = "Filename";
    public static String IMAGE_URI = "ImageUri";
    public static String ERROR_MESSAGE = "ErrorMessage";

    private Camera camera;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(getIdForLayout("grip_camera_preview_layout"));
        setImageViewBitmap("guide_top_left", "guide_top_left.png");
        setImageViewBitmap("guide_top_right", "guide_top_right.png");
        setImageViewBitmap("guide_bottom_left", "guide_bottom_left.png");
        setImageViewBitmap("guide_bottom_right", "guide_bottom_right.png");
        setImageButtonBitmap("capture_button", "camera_enabled_icon.png");
        ImageButton captureButton = (ImageButton)findViewById(getIdForUiElement("capture_button"));
        captureButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                camera.takePicture(null, null, pictureCallback);
            }
        });
    }

    private void setImageButtonBitmap(String name, String imageName) {
        setImageViewBitmap(name, imageName);
    }

    private void setImageViewBitmap(String name, String imageName) {
        try {
            InputStream imageStream = getAssets().open("www/images/cameraoverlay/" + imageName);
            Bitmap bitmap = BitmapFactory.decodeStream(imageStream);
            ImageView imageView = (ImageView)findViewById(getIdForUiElement(name));
            imageView.setImageBitmap(bitmap);
            imageStream.close();
        } catch (Exception e) {
            Log.e(TAG, "Could load image", e);
        }
    }

    private int getIdForLayout(String idAsString) {
        return getResources().getIdentifier(idAsString, "layout", getCallingPackage());
    }

    private int getIdForUiElement(String idAsString) {
        return getResources().getIdentifier(idAsString, "id", getCallingPackage());
    }

    private final PictureCallback pictureCallback = new PictureCallback() {

        @Override
        public void onPictureTaken(byte[] jpegData, Camera camera) {
            try {
                String filename = getIntent().getExtras().getString(FILENAME);
                File capturedImageFile = new File(getCacheDir(), filename);
                writeBytesToFile(jpegData, capturedImageFile);
                Intent data = new Intent();
                data.putExtra(IMAGE_URI, Uri.fromFile(capturedImageFile).toString());
                setResult(RESULT_OK, data);
                finish();
            } catch (Exception e) {
                finishWithError("Failed to save image");
            }
        }
    };

    private void writeBytesToFile(byte[] bytes, File file) throws IOException {
        FileOutputStream fos = new FileOutputStream(file);
        fos.write(bytes);
        fos.close();
    }

    private void finishWithError(String message) {
        Intent data = new Intent().putExtra(ERROR_MESSAGE, message);
        setResult(RESULT_CANCELED, data);
        finish();
    }

    @Override
    protected void onStart() {
        super.onStart();
        try {
            camera = Camera.open();
        } catch (Exception e) {
            finishWithError("Camera is not accessible");
        }
        if (camera != null) {
            displayCameraPreview();
        } else {
            finishWithError("Could not display camera preview");
        }
    }

    private void displayCameraPreview() {
        FrameLayout preview = (FrameLayout)findViewById(getIdForUiElement("grip_camera_preview"));
        preview.addView(new GripCameraPreview(this, camera));
    }

    @Override
    protected void onStop() {
        super.onStop();
        if (camera != null) {
            camera.release();
        }
    }

}
