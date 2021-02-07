package io.buildfoundation.bazel.detekt.value;

import com.squareup.moshi.Json;

public final class WorkResponse {

    @Json(name = "exitCode")
    public int exitCode;

    @Json(name = "output")
    public String output;

    @Json(name = "requestId")
    public int requestId;

    @Override
    public boolean equals(Object obj) {
        if (obj instanceof WorkResponse) {
            WorkResponse response = (WorkResponse) obj;

            return response.requestId == requestId && response.exitCode == exitCode && response.output == output;
        } else {
            return false;
        }
    }

    @Override
    public int hashCode() {
        return requestId;
    }
}
