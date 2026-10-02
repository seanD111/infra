{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        PairableTimeout = 30;
        DiscoverableTimeout = 30;
        MaxControllers = 1;
        TemporaryTimeout = 0;
        Privacy = "network/on";
      };
      Policy.AutoEnable = false;
    };
  };
}
