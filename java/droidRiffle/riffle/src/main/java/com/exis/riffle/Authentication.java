package com.exis.riffle;

import java.util.HashMap;
import java.util.Map;

import okhttp3.HttpUrl;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.Body;
import retrofit2.http.FieldMap;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Path;
import retrofit2.http.Query;

/**
 * Created by damouse on 4/9/16.
 */
public class Authentication {
    private static String PROD_REGISTRAR= "https://node.exis.io";
    Auth auth;

    public Authentication() {
        this(PROD_REGISTRAR);
    }

    Authentication(String url) {
        HttpUrl built = new HttpUrl.Builder().host(url).port(8880).build();

        auth = new Retrofit.Builder()
                .baseUrl(url)
                .addConverterFactory(GsonConverterFactory.create())
                .build().create(Auth.class);
    }

    public void register(String domain, String requestingDomain, String password, String email, String name) {
        Riffle.debug("Attempting registration...");
        Map<String, String> contents = new HashMap<>();

        contents.put("domain", domain);
        contents.put("requestingdomain", requestingDomain);
        contents.put("domain-password", password);
        contents.put("domain-email", email);
        contents.put("Name", name);

        Call<String> call = auth.register(contents);

        call.enqueue(new Callback<String>() {
            @Override
            public void onResponse(Call<String> call, Response<String> response) {
                int statusCode = response.code();
                System.out.println("Result: " + response.body());
            }

            @Override
            public void onFailure(Call<String> call, Throwable t) {
                Riffle.error("Could not register: " + t.getLocalizedMessage());
            }
        });
    }

    public interface Auth {
        @FormUrlEncoded
        @POST("some/endpoint")
        Call<String> register(@FieldMap Map<String, String> credentials);

    }
}
