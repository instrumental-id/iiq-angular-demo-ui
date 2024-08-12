package com.identityworksllc.iiq.angulardemo;

import sailpoint.rest.plugin.BasePluginResource;
import sailpoint.rest.plugin.SystemAdmin;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Response;

@Path("AngularDemoResource")
@Produces("application/json")
@SystemAdmin
public class AngularDemoResource extends BasePluginResource {
    @GET
    public Response testGet() {
        return Response.ok().entity("hi").build();
    }

    @Override
    public String getPluginName() {
        return "IDWAngularDemo";
    }
}
