locals {
  health_alarm_notify = base64encode(templatefile("${path.module}/src/health_alarm_notify.template.conf",
    {
      discord_webhook_url = var.discord_notification_settings.webhook_url
      discord_channel     = var.discord_notification_settings.channel
    }
  ))
}
