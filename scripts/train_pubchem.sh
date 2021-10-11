#!/bin/bash

NUM_NODES=1
NUM_GPUS_PER_NODE=4
NODE_RANK=0

BATCH_SIZE=256
ACCUM_STEP=1

MASTER_PORT=$(shuf -n 1 -i 10000-65535)

set -x

python -m torch.distributed.launch \
    --nproc_per_node=$NUM_GPUS_PER_NODE --nnodes=$NUM_NODES --node_rank $NODE_RANK --master_addr localhost --master_port $MASTER_PORT \
    train.py \
    --dataset chemdraw \
    --data_path data/molbank \
    --train_file pubchem/train.csv \
    --valid_file indigo-data/valid.csv \
    --test_file indigo-data/test.csv \
    --formats atomtok \
    --input_size 384 \
    --encoder swin_base_patch4_window12_384 \
    --decoder_scale 2 \
    --encoder_lr 4e-4 \
    --decoder_lr 4e-4 \
    --dynamic_indigo \
    --augment \
    --save_mode last \
    --save_path output/pubchem/swin_base_50_200k \
    --trunc_train 200000 \
    --label_smoothing 0.1 \
    --epochs 50 \
    --train_steps_per_epoch 3000 \
    --batch_size $((BATCH_SIZE / NUM_GPUS_PER_NODE / ACCUM_STEP)) \
    --gradient_accumulation_steps $ACCUM_STEP \
    --use_checkpoint \
    --warmup 0.05 \
    --print_freq 100 \
    --do_train --do_valid \
    --fp16 --backend nccl


#    --valid_file indigo-data/valid.csv \
#    --valid_file real-acs-evaluation/test.csv \
#    --save_path output/indigo/swin_base_20_dynamic_aug \
#    --no_pretrained --scheduler cosine --warmup 0.05 \
#    --load_path output/pubchem/swin_base_10 --resume \