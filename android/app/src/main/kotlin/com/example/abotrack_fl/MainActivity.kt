import androidx.work.Configuration
import io.flutter.app.FlutterApplication
import io.flutter.plugins.workmanager.WorkmanagerPlugin

class MyApplication : FlutterApplication(), Configuration.Provider {
  override fun onCreate() {
    super.onCreate()
    WorkmanagerPlugin.setPluginRegistrantCallback { registry ->
      // Register your WorkManager tasks here
    }
  }

  override fun getWorkManagerConfiguration(): Configuration {
    return Configuration.Builder().setMinimumLoggingLevel(android.util.Log.DEBUG).build()
  }
}
