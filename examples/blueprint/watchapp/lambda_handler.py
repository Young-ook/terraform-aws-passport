import json
import os
import logging
import urllib3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SLACK_WEBHOOK_URL = os.environ['SLACK_WEBHOOK_URL']
SLACK_CHANNEL = os.environ['SLACK_CHANNEL']

def lambda_handler(event, context):
    logger.info("Event: " + str(event))
    slack_message = message_formatter(event)

    # Post message on SLACK_WEBHOOK_URL
    http = urllib3.PoolManager()
    req = http.request('POST',
        SLACK_WEBHOOK_URL,
        body=json.dumps(slack_message),
        headers={'Content-Type': 'application/json'}
    )

def message_formatter(event):
    role = event['detail']['requestParameters']['roleArn']
    user = event['detail']['userIdentity']['userName']

    message = {
        'channel': SLACK_CHANNEL,
        'attachments' : [{
            'blocks': [{
                'type': 'section',
                'text' : {
                    'type': 'mrkdwn',
                    'text': "*Role*\n"
                }
            }, {
                'type': 'section',
                'text' : {
                    'type': 'plain_text',
                    'emoji': False,
                    'text': "%s" % (role)
                }
            }, {
                'type': 'section',
                'text' : {
                    'type': 'mrkdwn',
                    'text': "*User*\n"
                }
            }, {
                'type': 'section',
                'text' : {
                    'type': 'plain_text',
                    'emoji': False,
                    'text': "%s" % (user)
                }
            }]
        }]
    }
    return message
