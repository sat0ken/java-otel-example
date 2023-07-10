package com.example.demo;


import com.google.cloud.functions.HttpRequest;
import com.google.cloud.functions.HttpResponse;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.StringWriter;

import static com.google.common.truth.Truth.assertThat;
import static org.mockito.Mockito.when;

@RunWith(JUnit4.class)
class DemoApplicationTests {
    @Mock private HttpRequest request;
    @Mock private HttpResponse response;

    private BufferedWriter writerOut;
    private StringWriter responseOut;

    @Before
    public void beforeTest() throws IOException {
        MockitoAnnotations.openMocks(this);

        responseOut = new StringWriter();
        writerOut = new BufferedWriter(responseOut);
        when(response.getWriter()).thenReturn(writerOut);
    }

    @Test
    public void demoApplicationTests() throws IOException {
        new DemoApplication().service(request, response);
        writerOut.flush();
        assertThat(responseOut.toString().contains("Hello World!"));
    }

}
