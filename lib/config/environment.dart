enum AppEnv { dev, prod, local }

abstract class Environment {
  String name;
  String baseUrl;
  String resourceUrl;

  Environment(
      {required this.baseUrl, required this.resourceUrl, required this.name});

  factory Environment.fromEnv(AppEnv appEnv) {
    if (appEnv == AppEnv.local) {
      return LocalEnvironment();
    } else if (appEnv == AppEnv.dev) {
      return DevEnvironment();
    } else {
      return ProdEnvironment();
    }
  }



  Future<void> map({
    required Future<void> Function() prod,
    required Future<void> Function() dev,
    required Future<void> Function() local,
  }) async {
    if (this is ProdEnvironment) {
      await prod();
    } else if (this is DevEnvironment) {
      await dev();
    } else if (this is LocalEnvironment) {
      // Handle local environment
      await local();
    }
  }
}

/// ================= Local =======================
class LocalEnvironment extends Environment {
  LocalEnvironment()
      : super(
          name: 'Local',
          baseUrl: 'http://192.168.18.38:8000/', // Local API base URL
          resourceUrl: 'http://192.168.146.178:8080/',
        );
}

/// ================= Development =======================
class DevEnvironment extends Environment {
  DevEnvironment()
      : super(
          name: 'Dev',
          baseUrl: 'http://192.168.100.56:8000',
          resourceUrl: 'http://192.168.18.9:8005',
        );
}

/// ================= Production =======================
class ProdEnvironment extends Environment {
  ProdEnvironment()
      : super(
          name: 'Prod',
          baseUrl: 'http://54.186.154.3:8000',
          resourceUrl: 'http://192.168.146.178:8080/',
        );
}
