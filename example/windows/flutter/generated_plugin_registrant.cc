//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <ton/ton_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  TonPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TonPluginCApi"));
}
