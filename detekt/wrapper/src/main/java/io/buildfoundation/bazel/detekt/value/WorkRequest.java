package io.buildfoundation.bazel.detekt.value;

import com.squareup.moshi.Json;

import java.util.List;

public final class WorkRequest {

    @Json(name = "arguments")
    public List<String> arguments;

    @Json(name = "requestId")
    public int requestId;

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof WorkRequest) {
            WorkRequest request = (WorkRequest) obj;

            return request.requestId == requestId && request.arguments.equals(arguments);
        } else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return requestId;
    }
}
