
package com.performanceactive.gripcamera;

import android.app.Activity;
import android.content.Intent;
import android.hardware.Camera;
import android.hardware.Camera.PictureCallback;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageButton;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import static com.performanceactive.gripcamera.R.id.capture_button;
import static com.performanceactive.gripcamera.R.id.grip_camera_preview;
import static com.performanceactive.gripcamera.R.layout.grip_camera_preview_layout;

public class GripCameraActivity extends Activity {

    public static String FILENAME = "Filename";
    public static String IMAGE_URI = "ImageUri";
    public static String ERROR_MESSAGE = "ErrorMessage";

    private Camera camera;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(grip_camera_preview_layout);
        ImageButton captureButton = (ImageButton)findViewById(capture_button);
        captureButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                camera.takePicture(null, null, pictureCallback);
            }
        });
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
        FrameLayout preview = (FrameLayout)findViewById(grip_camera_preview);
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
