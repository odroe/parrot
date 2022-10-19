part of parrot.cmd;

final Set<Provider> _sharedProviders = {
  _commandRunnerProvider,
  argParserProvider,
  CommandRunnrtInfo.provider,
};

final Module commandModule = Module(
  providers: _sharedProviders,
  exports: _sharedProviders,
);
