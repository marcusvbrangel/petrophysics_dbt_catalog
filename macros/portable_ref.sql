{% macro portable_ref(model_name) %}
  {{ return(ref(model_name).include(database=false)) }}
{% endmacro %}
