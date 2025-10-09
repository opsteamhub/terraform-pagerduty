# PagerDuty Terraform Module - Examples

This directory contains practical examples demonstrating different use cases and configurations for the PagerDuty Terraform module.

## Examples Overview

### 1. Basic Example (`basic-example.tf`)
**Use Case**: Simple setup for small teams or getting started
- Single service configuration
- One user with admin role
- Basic on-call schedule
- Minimal escalation policy

**Best For**:
- Small teams (1-5 people)
- Simple monitoring setups
- Testing the module
- Getting familiar with PagerDuty concepts

### 2. Complete Example (`complete-example.tf`)
**Use Case**: Comprehensive enterprise setup
- Multiple services with different priorities
- Multiple users with various roles and timezones
- Complex escalation policies
- Both Slack and Prometheus integrations
- Business hours restrictions

**Best For**:
- Large organizations
- Multiple teams and services
- Complex escalation requirements
- Global teams across timezones

### 3. Prometheus Integration (`prometheus-integration.tf`)
**Use Case**: Monitoring-focused setup optimized for Prometheus
- Services organized by alert severity (critical, warning, infrastructure)
- SRE team structure
- 24/7 coverage schedules
- Complete Alertmanager configuration output

**Best For**:
- Organizations using Prometheus for monitoring
- SRE teams
- Infrastructure monitoring
- Automated alerting workflows

### 4. Slack Integration (`slack-integration.tf`)
**Use Case**: Team collaboration with Slack notifications
- Multiple Slack channels for different alert types
- Different notification strategies per service
- Mixed integration approach (some services with/without Slack)

**Best For**:
- Teams heavily using Slack
- Different notification channels for different severities
- Collaborative incident response

## How to Use These Examples

### Prerequisites
1. PagerDuty account with API access
2. PagerDuty API token and user token
3. For Slack examples: Slack workspace with PagerDuty app installed
4. Terraform >= 0.13 installed

### Running an Example

1. **Choose an example** that matches your use case
2. **Copy the example file** to your working directory
3. **Update variables** with your actual values:
   ```bash
   # Create a terraform.tfvars file
   cat > terraform.tfvars << EOF
   pagerduty_token      = "your-api-token-here"
   pagerduty_user_token = "your-user-token-here"
   slack_workspace_id   = "T1234567890"  # If using Slack examples
   EOF
   ```
4. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Customization Tips

#### Modifying Users
```hcl
users = {
  "your-email@company.com" = {
    user_name      = "Your Name"
    user_email     = "your-email@company.com"
    user_role      = "user"           # or "admin", "manager"
    user_time_zone = "America/New_York"
    country_code   = "+1"
    phone          = "5551234567"
    label          = "Work"
  }
}
```

#### Adjusting Escalation Timing
```hcl
rules = [
  {
    name                        = "First Response"
    escalation_delay_in_minutes = 5    # Escalate after 5 minutes
    targets = [...]
  },
  {
    name                        = "Second Level"
    escalation_delay_in_minutes = 15   # Then escalate after 15 more minutes
    targets = [...]
  }
]
```

#### Schedule Rotation Patterns
```hcl
# Daily rotation
rotation_turn_length_seconds = 86400    # 24 hours

# Weekly rotation  
rotation_turn_length_seconds = 604800   # 7 days

# Bi-weekly rotation
rotation_turn_length_seconds = 1209600  # 14 days
```

## Integration Outputs

Each example provides outputs that can be used with other tools:

### Prometheus Alertmanager
```yaml
# Use the integration keys in your alertmanager.yml
receivers:
  - name: 'pagerduty-critical'
    pagerduty_configs:
      - routing_key: 'OUTPUT_FROM_TERRAFORM'
```

### Slack Channel IDs
Find your Slack channel IDs:
1. Right-click on a Slack channel
2. Select "Copy link"
3. The ID is the last part: `https://yourworkspace.slack.com/channels/C1234567890`

### Workspace ID
Get your Slack workspace ID:
1. Go to https://api.slack.com/methods/auth.test
2. Use a test token to see your workspace ID

## Common Patterns

### Business Hours Only
```hcl
restriction = [
  {
    create_restriction = true
    type              = "weekly_restriction"
    start_time_of_day = "08:00:00"
    duration_seconds  = 36000      # 10 hours (8 AM to 6 PM)
    start_day_of_week = 1          # Monday
  }
]
```

### 24/7 Coverage
```hcl
# No restrictions = 24/7 coverage
restriction = []
```

### Multi-timezone Teams
```hcl
users = {
  "us-engineer@company.com" = {
    user_time_zone = "America/New_York"
    # ...
  }
  "eu-engineer@company.com" = {
    user_time_zone = "Europe/London"
    # ...
  }
  "asia-engineer@company.com" = {
    user_time_zone = "Asia/Tokyo"
    # ...
  }
}
```

## Troubleshooting

### Common Issues

1. **Invalid User Email**: Ensure email addresses are valid and not already in use
2. **Schedule Conflicts**: Users must exist before being assigned to schedules
3. **Slack Integration**: Verify workspace and channel IDs are correct
4. **Token Permissions**: Ensure API tokens have sufficient permissions

### Validation Commands
```bash
# Validate configuration
terraform validate

# Check what will be created
terraform plan

# See current state
terraform show
```

## Next Steps

After running an example:
1. **Test the setup** by triggering a test incident
2. **Verify notifications** are working (phone, SMS, Slack)
3. **Adjust timing** based on your team's response patterns
4. **Add more services** as needed
5. **Integrate with monitoring tools** using the output keys

## Support

For issues with:
- **Terraform module**: Check the main README.md
- **PagerDuty API**: Consult PagerDuty documentation
- **Slack integration**: Verify PagerDuty app installation in Slack