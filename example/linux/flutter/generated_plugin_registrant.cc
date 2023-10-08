//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <ton/ton_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) ton_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "TonPlugin");
  ton_plugin_register_with_registrar(ton_registrar);
}
