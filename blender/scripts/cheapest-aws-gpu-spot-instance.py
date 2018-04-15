#!/usr/bin/env python3
"""Script locating the cheapest AWS GPU compute spot instance for blender."""
"""based on https://gist.github.com/ahoereth/cb8c55e930695056b9600dc25f2329b9"""
from argparse import ArgumentParser
from datetime import datetime, timedelta
from itertools import groupby
from operator import itemgetter

import boto3
import numpy as np

AMIS = {
    #deep learning ubuntu: https://aws.amazon.com/marketplace/pp/B077GCH38C?qid=1523264428425&sr=0-6&ref_=srh_res_product_title
    #https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
    ('p2.xlarge', 'us-east-1',     ): 'ami-bc09d9c1',
    ('p2.xlarge', 'us-east-2',     ): 'ami-5b22133e',
    ('p2.xlarge', 'us-west-2',     ): 'ami-d2c759aa',
    ('p2.xlarge', 'eu-central-1',  ): 'ami-e77f260c',
    ('p2.xlarge', 'eu-west-1',     ): 'ami-0bc19972',
    ('p2.xlarge', 'ap-southeast-1',): 'ami-627a5d1e',
    ('p2.xlarge', 'ap-southeast-2',): 'ami-30a76e52',
    ('p2.xlarge', 'ap-northeast-2',): 'ami-ab13bcc5',
    ('p2.xlarge', 'ap-northeast-1',): 'ami-e65e4d9a',
    ('p2.xlarge', 'ap-south-1',    ): 'ami-1b240074',
}

CITIES = {
    'us-east-1':      'N. Virginia',
    'us-east-2':      'Ohio',
    'us-west-2':      'Oregon',
    'eu-central-1':   'Frankfurt',
    'eu-west-1':      'Ireland',
    'ap-southeast-1': 'Singapure',
    'ap-southeast-2': 'Sydney',
    'ap-northeast-2': 'Seoul',
    'ap-northeast-1': 'Tokyo',
    'ap-south-1':     'Mumbai',
}

def get_avg_price(instance_type, hours=5, aws_access_key=None, aws_secret_key=None):
    """Get up to date average price for a specific instance type."""
    kwargs = {'aws_access_key_id': aws_access_key, 'aws_secret_access_key': aws_secret_key}

    clients = []
    for AMI in AMIS:
        clients.append(boto3.client('ec2', region_name=AMI[1], **kwargs))

    prices = []
    for client in clients:
        zones = client.describe_availability_zones()
        zones = [zone['ZoneName'] for zone in zones['AvailabilityZones']]
        history = client.describe_spot_price_history(
            StartTime=datetime.today() - timedelta(hours=hours),
            EndTime=datetime.today(),
            InstanceTypes=[instance_type],
            ProductDescriptions=['Linux/UNIX'],
            Filters=[{'Name': 'availability-zone', 'Values': zones}],
        )
        history = history['SpotPriceHistory']
        grouper = itemgetter('AvailabilityZone')
        for zone, items in groupby(sorted(history, key=grouper), key=grouper):
            price = np.mean([float(i['SpotPrice']) for i in items])
            print('Checking {} zone price => {}'.format(zone, price))
            prices.append((zone, price))
    return sorted(prices, key=lambda t: t[1])

def main(instance_type, max_price_overhead, hours, aws_access_key, aws_secret_key):
    """Find cheapest region and provide launch command."""
    averages = get_avg_price(instance_type, hours, aws_access_key, aws_secret_key)
    zone, price = averages[0]
    ami = (instance_type, zone[:-1])
    print('\nInstances of type {instance_type} are cheapest in region {zone} ({city}) '
          'with an average price of ${price:.4f} over the last {hours} hours.'
          .format(instance_type=instance_type, zone=zone, city=CITIES[zone[:-1]], price=price,
                  hours=hours))
    print('\nUse the following commands to set the appropiate variables prior to launching "terraform apply"')
    print()
    print('export TF_VAR_aws_access_key={}'.format(aws_access_key))
    print('export TF_VAR_aws_secret_key={}'.format(aws_secret_key))
    print('export TF_VAR_aws_region={}'.format(zone[:-1]))
    print('export TF_VAR_aws_ami={}'.format(AMIS[ami]))
    print('export TF_VAR_aws_spot_price={}'.format(price))
    print()
    print('export TF_VAR_sheepit_user=your_username')
    print('export TF_VAR_sheepit_password=your_password')

if __name__ == '__main__':
    ARGS = ArgumentParser()
    ARGS.add_argument('-t', '--instance-type', default='p2.xlarge')
    ARGS.add_argument('--max-price-overhead', default=.1, type=float)
    ARGS.add_argument('--hours', default=5, type=float)
    ARGS.add_argument('--aws-access-key', required=True)
    ARGS.add_argument('--aws-secret-key', required=True)
    main(**vars(ARGS.parse_args()))
