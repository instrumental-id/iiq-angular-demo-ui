package com.identityworksllc.iiq.angulardemo;

import sailpoint.rest.plugin.BasePluginResource;
import sailpoint.rest.plugin.SystemAdmin;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import static com.identityworksllc.iiq.angulardemo.PluginConstants.PLUGIN_BASE_PATH;

/**
 * A simple demo resource for the Angular example plugin
 */
@Path(PLUGIN_BASE_PATH + "/demo")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@SystemAdmin
public class AngularDemoResource extends BasePluginResource {
    /**
     * Gets the plugin name
     * @return The plugin name
     */
    @Override
    public String getPluginName() {
        return PluginConstants.PLUGIN_NAME;
    }

    /**
     * A simple GET test endpoint
     * @return A simple "hi" response
     */
    @GET
    public Response testGet() {
        return Response.ok().entity("hi").build();
    }
}
