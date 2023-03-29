package com.example.flutter_export_video_frames;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterExportVideoFramesPlugin */
public class FlutterExportVideoFramesPlugin implements FlutterPlugin, MethodCallHandler {
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "export_video_frame");
    FileStorage.share().setContext(registrar.context());
    AblumSaver.share().setCurrent(registrar.context());
    PermissionManager.current().setActivity(registrar.activity());
    ExportVideoFramePlugin plugin = new ExportVideoFramePlugin();
    plugin.setRegistrar(registrar);
    channel.setMethodCallHandler(plugin);
  }

  private Registrar registrar;

  public void setRegistrar(Registrar registrar) {
    this.registrar = registrar;
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    if (!PermissionManager.current().isPermissionGranted()) {
      PermissionManager.current().askForPermission();
    }
    if (!(FileStorage.isExternalStorageReadable() && FileStorage.isExternalStorageWritable())) {
      result.error("File permission exception","Not get external storage permission",null);
      return;
    }

    switch (call.method) {
      case "cleanImageCache": {
        Boolean success = FileStorage.share().cleanCache();
        if (success) {
          result.success("success");
        } else {
          result.error("Clean exception", "Fail", null);
        }
        break;
      }
      case "saveImage": {
        String filePath = call.argument("filePath").toString();
        String albumName = call.argument("albumName").toString();
        Bitmap waterBitMap = null;
        PointF waterPoint = null;
        Double scale = 1.0;
        AblumSaver.share().setAlbumName(albumName);
        if (call.argument("waterMark") != null && call.argument("alignment") != null) {
          String waterPathKey = call.argument("waterMark").toString();
          AssetManager assetManager = registrar.context().getAssets();
          String key = registrar.lookupKeyForAsset(waterPathKey);
          Map<String,Number> rect = call.argument("alignment");
          Double x = rect.get("x").doubleValue();
          Double y = rect.get("y").doubleValue();
          waterPoint = new PointF(x.floatValue(),y.floatValue());
          Number number = call.argument("scale");
          scale = number.doubleValue();
          try {
            InputStream in = assetManager.open(key);
            waterBitMap = BitmapFactory.decodeStream(in);
          } catch (Exception e) {
            e.printStackTrace();
          }
        }
        AblumSaver.share().saveToAlbum(filePath,waterBitMap,waterPoint,scale.floatValue(),result);
        break;
      }
      case "exportGifImagePathList": {
        String filePath = call.argument("filePath").toString();
        Number quality = call.argument("quality");
        ExportImageTask task = new ExportImageTask();
        task.execute(filePath,quality);
        task.setCallBack(new Callback() {
          @Override
          public void exportPath(ArrayList<String> list) {
            if (list != null) {
              result.success(list);
            } else {
              result.error("Media exception","Get frame fail", null);
            }
          }
        });
        break;
      }
      case "exportImage": {
        String filePath = call.argument("filePath").toString();
        Number number = call.argument("number");
        Number quality = call.argument("quality");
        ExportImageTask task = new ExportImageTask();
        task.execute(filePath,number.intValue(),quality);
        task.setCallBack(new Callback() {
          @Override
          public void exportPath(ArrayList<String> list) {
            if (list != null) {
              result.success(list);
            } else {
              result.error("Media exception","Get frame fail", null);
            }
          }
        });
        break;
      }
      case "exportImageBySeconds": {
        String filePath = call.argument("filePath").toString();
        Number duration = call.argument("duration");
        Number radian = call.argument("radian");
        ExportImageTask task = new ExportImageTask();
        task.execute(filePath,duration.longValue(),radian);
        task.setCallBack(new Callback() {
          @Override
          public void exportPath(ArrayList<String> list) {
            if ((list != null) && (list.size() > 0)) {
              result.success(list.get(0));
            } else {
              result.error("Media exception","Get frame fail", null);
            }
          }
        });
        break;
      }
      default:
        result.notImplemented();
        break;
    }

  }
}
