package com.identityworksllc.iiq.angulardemo;

import sailpoint.plugin.PluginBaseHelper;
import sailpoint.rest.plugin.BasePluginResource;
import sailpoint.rest.plugin.Deferred;
import sailpoint.rest.plugin.RequiredRight;
import sailpoint.rest.plugin.SystemAdmin;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Response;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Path("AngularDemoResource")
@Produces("application/json")
@SystemAdmin
public class AngularDemoResource extends BasePluginResource {
    @GET
    public Response testGet() {
        return Response.ok().entity("hi").build();
    }

    public Response databaseQuery() {
        List<Map<String, Object>> output = new ArrayList<>();
        try (Connection db = PluginBaseHelper.getConnection()) {

        }
        return Response.ok().entity(output).build();
    }

    @Override
    public String getPluginName() {
        return "IDWAngularDemo";
    }
}
