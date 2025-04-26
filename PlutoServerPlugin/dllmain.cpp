#include <Windows.h>
#include "plutonium-sdk/plutonium_sdk.hpp"

std::unique_ptr<plutonium::sdk::plugin> plugin_;
class plugin_impl : public plutonium::sdk::plugin
{
public:
    const char* plugin_name() override
    {
        return "PlutoServer";
    }

    void on_startup(plutonium::sdk::iinterface* interface_ptr, plutonium::sdk::game game) override
    {
        interface_ptr->logging()->info("Plugin starting!");
    }

    void on_shutdown() override
    {
        // shutdown code
    }
};

PLUTONIUM_API plutonium::sdk::plugin* on_initialize() {
    return (plugin_ = std::make_unique<plugin_impl>()).get();
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    return TRUE;
}

