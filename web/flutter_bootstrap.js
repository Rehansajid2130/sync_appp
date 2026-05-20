{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      // Serve CanvasKit assets locally from the web server instead of gstatic CDN
      canvasKitBaseUrl: "canvaskit/"
    });
    await appRunner.runApp();
  }
});
