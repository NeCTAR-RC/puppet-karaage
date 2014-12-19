# Locally defined Karaage-admin settings

TEMPLATE_DIRS = (
    # Put strings here, like "/home/html/django_templates" or "C:/www/django/templates".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    "/etc/karaage/templates",
    <% if @develop -%>
    '/opt/karaage-admin/templates',
    <%- end %>
)

STATIC_ROOT = "/var/lib/karaage-admin/static/"
