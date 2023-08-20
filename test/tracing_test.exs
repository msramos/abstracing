defmodule TracingTest do
  use ExUnit.Case

  require Record
  @fields Record.extract(:span, from: "deps/opentelemetry/include/otel_span.hrl")
  Record.defrecordp(:span, @fields)

  defmodule Example do
    use Tracing

    def variation_1 do
      span do
        {:ok, :variation_1}
      end
    end

    def variation_2 do
      start_opts = Tracing.build_span_opts(attributes: %{xpto: "xablau"})

      span start_opts do
        {:ok, :variation_2}
      end
    end

    def variation_3 do
      start_opts = Tracing.build_span_opts(kind: :client, attributes: %{xpto: "xablau"})

      span start_opts, "custom_name" do
        {:ok, :variation_3}
      end
    end

    def variation_4 do
      span %{}, span_name() do
        Tracing.set_attribute("attrs", %{x: 1, y: 2})

        variation_1()
      end
    end

    def variation_5 do
      span do
        Tracing.set_attribute("attrs", {:ok, {%{id: 1}, %{id: 2}}})
        {:ok, {%{id: 1}, %{id: 2}}}
      end
    end

    def variation_6 do
      span do
        variation_7()
      end
    end

    def variation_7 do
      span do
        raise ArgumentError
      end
    end

    defp span_name do
      "function_name"
    end
  end

  setup do
    Application.load(:opentelemetry)

    Application.put_env(:opentelemetry, :processors, [
      {:otel_simple_processor, %{exporter: {:otel_exporter_pid, self()}}}
    ])

    {:ok, _} = Application.ensure_all_started(:opentelemetry)

    on_exit(fn ->
      Application.stop(:opentelemetry)
      Application.unload(:opentelemetry)
    end)
  end

  describe "span/3" do
    test "creates spans with default name and no attributes" do
      assert {:ok, :variation_1} == Example.variation_1()

      assert_receive {:span, span(name: "TracingTest.Example.variation_1/0")}
    end

    test "creates spans with default name and custom attributes" do
      assert {:ok, :variation_2} == Example.variation_2()

      :otel_tracer_provider.force_flush()

      attributes = :otel_attributes.new([xpto: "xablau"], 128, :infinity)

      assert_receive {:span,
                      span(
                        name: "TracingTest.Example.variation_2/0",
                        attributes: ^attributes
                      )}
    end

    test "creates spans with custom name and custom attributes" do
      assert {:ok, :variation_3} == Example.variation_3()

      attributes = :otel_attributes.new([xpto: "xablau"], 128, :infinity)

      assert_receive {:span, span(name: "custom_name", kind: :client, attributes: ^attributes)}
    end

    test "creates multi spans" do
      assert {:ok, :variation_1} == Example.variation_4()

      attributes = :otel_attributes.new([{"attrs.x", "1"}, {"attrs.y", "2"}], 128, :infinity)

      assert_receive {:span, span(name: "TracingTest.Example.variation_1/0")}

      assert_receive {:span,
                      span(
                        name: "function_name",
                        attributes: ^attributes
                      )}
    end

    test "validate result with tuple and struct" do
      assert {:ok, conversations} = Example.variation_5()

      attributes =
        :otel_attributes.new(
          [{"attrs.0", ":ok"}, {"attrs.1", inspect(conversations)}],
          128,
          :infinity
        )

      assert_receive {:span,
                      span(
                        name: "TracingTest.Example.variation_5/0",
                        attributes: ^attributes
                      )}
    end

    test "handles raises in multi spans" do
      assert_raise ArgumentError, fn ->
        Example.variation_6()
      end

      assert_receive {:span,
                      span(
                        name: "TracingTest.Example.variation_7/0",
                        status: {:status, :error, "exception"}
                      )}

      assert_receive {:span,
                      span(
                        name: "TracingTest.Example.variation_6/0",
                        status: {:status, :error, "exception"}
                      )}
    end
  end

  describe "build_span_opts/1" do
    test "generates a map with the expected attributes" do
      result =
        Tracing.build_span_opts(
          kind: :consumer,
          attributes: %{user: "123"},
          links: [],
          start_time: 123,
          is_recording: true,
          foo: :bar,
          test_test: "test"
        )

      refute Map.has_key?(result, :foo)
      refute Map.has_key?(result, :test_test)

      for key <- [:kind, :attributes, :links, :start_time, :is_recording] do
        assert Map.has_key?(result, key)
      end
    end
  end
end
