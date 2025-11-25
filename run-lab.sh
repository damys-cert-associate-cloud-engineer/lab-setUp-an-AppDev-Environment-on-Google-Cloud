#!/bin/bash
# Set all variables to start de script
BUCKET_NAME=
REGION=
ZONE=
TOPIC_NAME=
FUNCTION_NAME=
USERNAME_2=

# Create a BUCKET by command line
gsutil mb -c standard -l $REGION gs://$BUCKET_NAME

# create a Pubsub topi by command line
gcloud pubsub topics create $TOPIC_NAME

# create a folder 
mkdir memories-thumbnail-generator

# move to folder generated
cd memories-thumbnail-generator

# run deploy cloud function
gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --region=$REGION \
  --runtime=nodejs24 \
  --entry-point=memories-thumbnail-generator \
  --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
  --trigger-event-filters="bucket=$BUCKET_NAME" \
  --quiet

# move image to test the service in Bucket via cloud
# 1. Download the image
curl -o local_image.jpg https://example.com/images/sample.jpg
# 2. Upload to the GCP bucket
gsutil cp local_image.jpg gs://$BUCKET_NAME/image_in_gcs.jpg
# 3. (Optional) Remove the local file
rm local_image.jpg

# Remove the user from IAM 
gcloud projects remove-iam-policy-binding $(gcloud config get-value project) \
  --member="user:$USERNAME_2" \
  --role="roles/viewer"
