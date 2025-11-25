#!/bin/bash
# Set all variables to start de script
BUCKET_NAME="qwiklabs-gcp-02-facd14dcd3c0-bucket"
REGION="us-east1"
ZONE="us-east1-c"
TOPIC_NAME="topic-memories-999"
FUNCTION_NAME="memories-thumbnail-creator"
SECOND_USERNAME="student-04-0e932f1e5503@qwiklabs.net"
NODEJS_VERSION="nodejs22"
ENTRY_POINT="memories-thumbnail-generator"
TRIGGER_FILTER_TYPE="type=google.cloud.storage.object.v1.finalized"


# activar api EVENTARC
gcloud services enable eventarc.googleapis.com

# Create a BUCKET by command line
gsutil mb -c standard -l $REGION gs://$BUCKET_NAME

# create a Pubsub topi by command line
gcloud pubsub topics create $TOPIC_NAME

# run deploy cloud function
gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --region=$REGION \
  --runtime=$NODEJS_VERSION \
  --entry-point=$ENTRY_POINT \
  --trigger-event-filters=$TRIGGER_FILTER_TYPE" \
  --trigger-event-filters="bucket=$BUCKET_NAME" \
  --quiet

gcloud eventarc triggers update trigger-hqqslzov \
--location=$REGION \
--service-account=qwiklabs-gcp-02-facd14dcd3c0@qwiklabs-gcp-02-facd14dcd3c0.iam.gserviceaccount.com \
--event-data-content-type=application/json \
--destination-run-service=$FUNCTION_NAME \
--destination-run-region=$REGION \
--destination-run-path="/" \
--event-filters=$TRIGGER_FILTER_TYPE \
--event-filters="bucket=$BUCKET_NAME"


# move image to test the service in Bucket via cloud
# 1. Download the image
curl -o local_image.jpg https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fphoto-image-art&psig=AOvVaw1L-wyPdG3DRoaFGjuw6sTG&ust=1764195247174000&source=images&opi=89978449
# 2. Upload to the GCP bucket
gsutil cp local_image.jpg gs://$BUCKET_NAME/image_in_gcs.jpg
# 3. (Optional) Remove the local file
rm local_image.jpg

# Remove the user from IAM 
gcloud projects remove-iam-policy-binding $(gcloud config get-value project) \
  --member="user:$SECOND_USERNAME" \
  --role="roles/viewer"
