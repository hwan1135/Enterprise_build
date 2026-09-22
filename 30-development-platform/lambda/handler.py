import json
import os
from datetime import datetime, timezone


def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "application": os.environ["APPLICATION"],
                "environment": os.environ["ENVIRONMENT"],
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "message": "Scheduled Lambda execution completed."
            }
        )
    }