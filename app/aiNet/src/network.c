/**
  ******************************************************************************
  * @file    network.c
  * @author  AST Embedded Analytics Research Platform
  * @date    2026-05-17T19:38:58+0800
  * @brief   AI Tool Automatic Code Generator for Embedded NN computing
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  ******************************************************************************
  */


#include "network.h"
#include "network_data.h"

#include "ai_platform.h"
#include "ai_platform_interface.h"
#include "ai_math_helpers.h"

#include "core_common.h"
#include "core_convert.h"

#include "layers.h"



#undef AI_NET_OBJ_INSTANCE
#define AI_NET_OBJ_INSTANCE g_network
 
#undef AI_NETWORK_MODEL_SIGNATURE
#define AI_NETWORK_MODEL_SIGNATURE     "0xde191db8988658dce0478e977d148225"

#ifndef AI_TOOLS_REVISION_ID
#define AI_TOOLS_REVISION_ID     ""
#endif

#undef AI_TOOLS_DATE_TIME
#define AI_TOOLS_DATE_TIME   "2026-05-17T19:38:58+0800"

#undef AI_TOOLS_COMPILE_TIME
#define AI_TOOLS_COMPILE_TIME    __DATE__ " " __TIME__

#undef AI_NETWORK_N_BATCHES
#define AI_NETWORK_N_BATCHES         (1)

static ai_ptr g_network_activations_map[1] = AI_C_ARRAY_INIT;
static ai_ptr g_network_weights_map[1] = AI_C_ARRAY_INIT;



/**  Array declarations section  **********************************************/
/* Array#0 */
AI_ARRAY_OBJ_DECLARE(
  input_output_array, AI_ARRAY_FORMAT_FLOAT|AI_FMT_FLAG_IS_IO,
  NULL, NULL, 1200, AI_STATIC)

/* Array#1 */
AI_ARRAY_OBJ_DECLARE(
  div_output_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1200, AI_STATIC)

/* Array#2 */
AI_ARRAY_OBJ_DECLARE(
  mul_output_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1200, AI_STATIC)

/* Array#3 */
AI_ARRAY_OBJ_DECLARE(
  sub_output_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1200, AI_STATIC)

/* Array#4 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_output_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 3200, AI_STATIC)

/* Array#5 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_1_output_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1600, AI_STATIC)

/* Array#6 */
AI_ARRAY_OBJ_DECLARE(
  _unsafe_view_to_chlast_output_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1600, AI_STATIC)

/* Array#7 */
AI_ARRAY_OBJ_DECLARE(
  linear_output_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 512, AI_STATIC)

/* Array#8 */
AI_ARRAY_OBJ_DECLARE(
  relu_2_output_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 512, AI_STATIC)

/* Array#9 */
AI_ARRAY_OBJ_DECLARE(
  output_output_array, AI_ARRAY_FORMAT_FLOAT|AI_FMT_FLAG_IS_IO,
  NULL, NULL, 2, AI_STATIC)

/* Array#10 */
AI_ARRAY_OBJ_DECLARE(
  val_0_2D_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1, AI_STATIC)

/* Array#11 */
AI_ARRAY_OBJ_DECLARE(
  val_2_2D_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1, AI_STATIC)

/* Array#12 */
AI_ARRAY_OBJ_DECLARE(
  mul_scale_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1200, AI_STATIC)

/* Array#13 */
AI_ARRAY_OBJ_DECLARE(
  mul_bias_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1200, AI_STATIC)

/* Array#14 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_weights_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 2400, AI_STATIC)

/* Array#15 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_bias_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 32, AI_STATIC)

/* Array#16 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_1_weights_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 51200, AI_STATIC)

/* Array#17 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_1_bias_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 64, AI_STATIC)

/* Array#18 */
AI_ARRAY_OBJ_DECLARE(
  linear_weights_array, AI_ARRAY_FORMAT_LUT8_FLOAT,
  NULL, NULL, 819200, AI_STATIC)

/* Array#19 */
AI_ARRAY_OBJ_DECLARE(
  linear_bias_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 512, AI_STATIC)

/* Array#20 */
AI_ARRAY_OBJ_DECLARE(
  output_weights_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1024, AI_STATIC)

/* Array#21 */
AI_ARRAY_OBJ_DECLARE(
  output_bias_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 2, AI_STATIC)

/* Array#22 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_scratch0_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 75, AI_STATIC)

/* Array#23 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_scratch1_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1280, AI_STATIC)

/* Array#24 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_1_scratch0_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 800, AI_STATIC)

/* Array#25 */
AI_ARRAY_OBJ_DECLARE(
  conv2d_1_scratch1_array, AI_ARRAY_FORMAT_FLOAT,
  NULL, NULL, 1280, AI_STATIC)

/**  Tensor declarations section  *********************************************/
/* Tensor #0 */
AI_TENSOR_OBJ_DECLARE(
  _unsafe_view_to_chlast_output, AI_STATIC,
  0, 0x0,
  AI_SHAPE_INIT(4, 1, 5, 5, 64), AI_STRIDE_INIT(4, 4, 4, 20, 100),
  1, &_unsafe_view_to_chlast_output_array, NULL)

/* Tensor #1 */
AI_TENSOR_OBJ_DECLARE(
  _unsafe_view_to_chlast_output0, AI_STATIC,
  1, 0x0,
  AI_SHAPE_INIT(4, 1, 1600, 1, 1), AI_STRIDE_INIT(4, 4, 4, 6400, 6400),
  1, &_unsafe_view_to_chlast_output_array, NULL)

/* Tensor #2 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_1_bias, AI_STATIC,
  2, 0x0,
  AI_SHAPE_INIT(4, 1, 64, 1, 1), AI_STRIDE_INIT(4, 4, 4, 256, 256),
  1, &conv2d_1_bias_array, NULL)

/* Tensor #3 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_1_output, AI_STATIC,
  3, 0x0,
  AI_SHAPE_INIT(4, 1, 64, 5, 5), AI_STRIDE_INIT(4, 4, 4, 256, 1280),
  1, &conv2d_1_output_array, NULL)

/* Tensor #4 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_1_scratch0, AI_STATIC,
  4, 0x0,
  AI_SHAPE_INIT(4, 1, 32, 5, 5), AI_STRIDE_INIT(4, 4, 4, 128, 640),
  1, &conv2d_1_scratch0_array, NULL)

/* Tensor #5 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_1_scratch1, AI_STATIC,
  5, 0x0,
  AI_SHAPE_INIT(4, 1, 64, 10, 2), AI_STRIDE_INIT(4, 4, 4, 256, 2560),
  1, &conv2d_1_scratch1_array, NULL)

/* Tensor #6 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_1_weights, AI_STATIC,
  6, 0x0,
  AI_SHAPE_INIT(4, 32, 5, 5, 64), AI_STRIDE_INIT(4, 4, 128, 8192, 40960),
  1, &conv2d_1_weights_array, NULL)

/* Tensor #7 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_bias, AI_STATIC,
  7, 0x0,
  AI_SHAPE_INIT(4, 1, 32, 1, 1), AI_STRIDE_INIT(4, 4, 4, 128, 128),
  1, &conv2d_bias_array, NULL)

/* Tensor #8 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_output, AI_STATIC,
  8, 0x0,
  AI_SHAPE_INIT(4, 1, 32, 10, 10), AI_STRIDE_INIT(4, 4, 4, 128, 1280),
  1, &conv2d_output_array, NULL)

/* Tensor #9 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_scratch0, AI_STATIC,
  9, 0x0,
  AI_SHAPE_INIT(4, 1, 3, 5, 5), AI_STRIDE_INIT(4, 4, 4, 12, 60),
  1, &conv2d_scratch0_array, NULL)

/* Tensor #10 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_scratch1, AI_STATIC,
  10, 0x0,
  AI_SHAPE_INIT(4, 1, 32, 20, 2), AI_STRIDE_INIT(4, 4, 4, 128, 2560),
  1, &conv2d_scratch1_array, NULL)

/* Tensor #11 */
AI_TENSOR_OBJ_DECLARE(
  conv2d_weights, AI_STATIC,
  11, 0x0,
  AI_SHAPE_INIT(4, 3, 5, 5, 32), AI_STRIDE_INIT(4, 4, 12, 384, 1920),
  1, &conv2d_weights_array, NULL)

/* Tensor #12 */
AI_TENSOR_OBJ_DECLARE(
  div_output, AI_STATIC,
  12, 0x0,
  AI_SHAPE_INIT(4, 1, 1200, 1, 1), AI_STRIDE_INIT(4, 4, 4, 4800, 4800),
  1, &div_output_array, NULL)

/* Tensor #13 */
AI_TENSOR_OBJ_DECLARE(
  input_output, AI_STATIC,
  13, 0x0,
  AI_SHAPE_INIT(4, 1, 1200, 1, 1), AI_STRIDE_INIT(4, 4, 4, 4800, 4800),
  1, &input_output_array, NULL)

/* Tensor #14 */
AI_TENSOR_OBJ_DECLARE(
  linear_bias, AI_STATIC,
  14, 0x0,
  AI_SHAPE_INIT(4, 1, 512, 1, 1), AI_STRIDE_INIT(4, 4, 4, 2048, 2048),
  1, &linear_bias_array, NULL)

/* Tensor #15 */
AI_TENSOR_OBJ_DECLARE(
  linear_output, AI_STATIC,
  15, 0x0,
  AI_SHAPE_INIT(4, 1, 512, 1, 1), AI_STRIDE_INIT(4, 4, 4, 2048, 2048),
  1, &linear_output_array, NULL)

/* Tensor #16 */
AI_TENSOR_OBJ_DECLARE(
  linear_weights, AI_STATIC,
  16, 0x0,
  AI_SHAPE_INIT(4, 1600, 512, 1, 1), AI_STRIDE_INIT(4, 1, 1600, 819200, 819200),
  1, &linear_weights_array, NULL)

/* Tensor #17 */
AI_TENSOR_OBJ_DECLARE(
  mul_bias, AI_STATIC,
  17, 0x0,
  AI_SHAPE_INIT(4, 1, 1200, 1, 1), AI_STRIDE_INIT(4, 4, 4, 4800, 4800),
  1, &mul_bias_array, NULL)

/* Tensor #18 */
AI_TENSOR_OBJ_DECLARE(
  mul_output, AI_STATIC,
  18, 0x0,
  AI_SHAPE_INIT(4, 1, 1200, 1, 1), AI_STRIDE_INIT(4, 4, 4, 4800, 4800),
  1, &mul_output_array, NULL)

/* Tensor #19 */
AI_TENSOR_OBJ_DECLARE(
  mul_scale, AI_STATIC,
  19, 0x0,
  AI_SHAPE_INIT(4, 1, 1200, 1, 1), AI_STRIDE_INIT(4, 4, 4, 4800, 4800),
  1, &mul_scale_array, NULL)

/* Tensor #20 */
AI_TENSOR_OBJ_DECLARE(
  output_bias, AI_STATIC,
  20, 0x0,
  AI_SHAPE_INIT(4, 1, 2, 1, 1), AI_STRIDE_INIT(4, 4, 4, 8, 8),
  1, &output_bias_array, NULL)

/* Tensor #21 */
AI_TENSOR_OBJ_DECLARE(
  output_output, AI_STATIC,
  21, 0x0,
  AI_SHAPE_INIT(4, 1, 2, 1, 1), AI_STRIDE_INIT(4, 4, 4, 8, 8),
  1, &output_output_array, NULL)

/* Tensor #22 */
AI_TENSOR_OBJ_DECLARE(
  output_weights, AI_STATIC,
  22, 0x0,
  AI_SHAPE_INIT(4, 512, 2, 1, 1), AI_STRIDE_INIT(4, 4, 2048, 4096, 4096),
  1, &output_weights_array, NULL)

/* Tensor #23 */
AI_TENSOR_OBJ_DECLARE(
  relu_2_output, AI_STATIC,
  23, 0x0,
  AI_SHAPE_INIT(4, 1, 512, 1, 1), AI_STRIDE_INIT(4, 4, 4, 2048, 2048),
  1, &relu_2_output_array, NULL)

/* Tensor #24 */
AI_TENSOR_OBJ_DECLARE(
  sub_output, AI_STATIC,
  24, 0x0,
  AI_SHAPE_INIT(4, 1, 1200, 1, 1), AI_STRIDE_INIT(4, 4, 4, 4800, 4800),
  1, &sub_output_array, NULL)

/* Tensor #25 */
AI_TENSOR_OBJ_DECLARE(
  sub_output0, AI_STATIC,
  25, 0x0,
  AI_SHAPE_INIT(4, 1, 3, 20, 20), AI_STRIDE_INIT(4, 4, 4, 12, 240),
  1, &sub_output_array, NULL)

/* Tensor #26 */
AI_TENSOR_OBJ_DECLARE(
  val_0_2D, AI_STATIC,
  26, 0x0,
  AI_SHAPE_INIT(4, 1, 1, 1, 1), AI_STRIDE_INIT(4, 4, 4, 4, 4),
  1, &val_0_2D_array, NULL)

/* Tensor #27 */
AI_TENSOR_OBJ_DECLARE(
  val_2_2D, AI_STATIC,
  27, 0x0,
  AI_SHAPE_INIT(4, 1, 1, 1, 1), AI_STRIDE_INIT(4, 4, 4, 4, 4),
  1, &val_2_2D_array, NULL)



/**  Layer declarations section  **********************************************/


AI_TENSOR_CHAIN_OBJ_DECLARE(
  output_chain, AI_STATIC_CONST, 4,
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &relu_2_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &output_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 2, &output_weights, &output_bias),
  AI_TENSOR_LIST_OBJ_EMPTY
)

AI_LAYER_OBJ_DECLARE(
  output_layer, 15,
  DENSE_TYPE, 0x0, NULL,
  dense, forward_dense,
  &output_chain,
  NULL, &output_layer, AI_STATIC, 
)

AI_TENSOR_CHAIN_OBJ_DECLARE(
  relu_2_chain, AI_STATIC_CONST, 4,
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &linear_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &relu_2_output),
  AI_TENSOR_LIST_OBJ_EMPTY,
  AI_TENSOR_LIST_OBJ_EMPTY
)

AI_LAYER_OBJ_DECLARE(
  relu_2_layer, 14,
  NL_TYPE, 0x0, NULL,
  nl, forward_relu,
  &relu_2_chain,
  NULL, &output_layer, AI_STATIC, 
  .nl_params = NULL, 
)

AI_TENSOR_CHAIN_OBJ_DECLARE(
  linear_chain, AI_STATIC_CONST, 4,
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &_unsafe_view_to_chlast_output0),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &linear_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 2, &linear_weights, &linear_bias),
  AI_TENSOR_LIST_OBJ_EMPTY
)

AI_LAYER_OBJ_DECLARE(
  linear_layer, 13,
  DENSE_TYPE, 0x0, NULL,
  dense, forward_dense,
  &linear_chain,
  NULL, &relu_2_layer, AI_STATIC, 
)

AI_TENSOR_CHAIN_OBJ_DECLARE(
  _unsafe_view_to_chlast_chain, AI_STATIC_CONST, 4,
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &conv2d_1_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &_unsafe_view_to_chlast_output),
  AI_TENSOR_LIST_OBJ_EMPTY,
  AI_TENSOR_LIST_OBJ_EMPTY
)

AI_LAYER_OBJ_DECLARE(
  _unsafe_view_to_chlast_layer, 12,
  TRANSPOSE_TYPE, 0x0, NULL,
  transpose, forward_transpose,
  &_unsafe_view_to_chlast_chain,
  NULL, &linear_layer, AI_STATIC, 
  .out_mapping = AI_SHAPE_INIT(6, AI_SHAPE_IN_CHANNEL, AI_SHAPE_WIDTH, AI_SHAPE_HEIGHT, AI_SHAPE_CHANNEL, AI_SHAPE_DEPTH, AI_SHAPE_EXTENSION), 
)

AI_TENSOR_CHAIN_OBJ_DECLARE(
  conv2d_1_chain, AI_STATIC_CONST, 4,
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &conv2d_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &conv2d_1_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 3, &conv2d_1_weights, &conv2d_1_bias, NULL),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 2, &conv2d_1_scratch0, &conv2d_1_scratch1)
)

AI_LAYER_OBJ_DECLARE(
  conv2d_1_layer, 11,
  OPTIMIZED_CONV2D_TYPE, 0x0, NULL,
  conv2d_nl_pool, forward_conv2d_if32of32wf32_nl_pool,
  &conv2d_1_chain,
  NULL, &_unsafe_view_to_chlast_layer, AI_STATIC, 
  .groups = 1, 
  .nl_params = NULL, 
  .nl_func = AI_HANDLE_PTR(forward_lite_nl_relu_if32of32), 
  .filter_stride = AI_SHAPE_2D_INIT(1, 1), 
  .dilation = AI_SHAPE_2D_INIT(1, 1), 
  .filter_pad = AI_SHAPE_INIT(4, 2, 2, 2, 2), 
  .pool_size = AI_SHAPE_2D_INIT(2, 2), 
  .pool_stride = AI_SHAPE_2D_INIT(2, 2), 
  .pool_pad = AI_SHAPE_INIT(4, 0, 0, 0, 0), 
  .pool_func = AI_HANDLE_PTR(pool_func_mp_array_f32), 
  .in_ch_format = AI_LAYER_FORMAT_CHANNEL_LAST_SAME, 
  .out_ch_format = AI_LAYER_FORMAT_CHANNEL_LAST_VALID, 
)

AI_TENSOR_CHAIN_OBJ_DECLARE(
  conv2d_chain, AI_STATIC_CONST, 4,
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &sub_output0),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &conv2d_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 3, &conv2d_weights, &conv2d_bias, NULL),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 2, &conv2d_scratch0, &conv2d_scratch1)
)

AI_LAYER_OBJ_DECLARE(
  conv2d_layer, 8,
  OPTIMIZED_CONV2D_TYPE, 0x0, NULL,
  conv2d_nl_pool, forward_conv2d_if32of32wf32_nl_pool,
  &conv2d_chain,
  NULL, &conv2d_1_layer, AI_STATIC, 
  .groups = 1, 
  .nl_params = NULL, 
  .nl_func = AI_HANDLE_PTR(forward_lite_nl_relu_if32of32), 
  .filter_stride = AI_SHAPE_2D_INIT(1, 1), 
  .dilation = AI_SHAPE_2D_INIT(1, 1), 
  .filter_pad = AI_SHAPE_INIT(4, 2, 2, 2, 2), 
  .pool_size = AI_SHAPE_2D_INIT(2, 2), 
  .pool_stride = AI_SHAPE_2D_INIT(2, 2), 
  .pool_pad = AI_SHAPE_INIT(4, 0, 0, 0, 0), 
  .pool_func = AI_HANDLE_PTR(pool_func_mp_array_f32), 
  .in_ch_format = AI_LAYER_FORMAT_CHANNEL_LAST_SAME, 
  .out_ch_format = AI_LAYER_FORMAT_CHANNEL_LAST_VALID, 
)

AI_TENSOR_CHAIN_OBJ_DECLARE(
  sub_chain, AI_STATIC_CONST, 4,
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 2, &mul_output, &val_2_2D),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &sub_output),
  AI_TENSOR_LIST_OBJ_EMPTY,
  AI_TENSOR_LIST_OBJ_EMPTY
)

AI_LAYER_OBJ_DECLARE(
  sub_layer, 3,
  ELTWISE_TYPE, 0x0, NULL,
  eltwise, forward_eltwise,
  &sub_chain,
  NULL, &conv2d_layer, AI_STATIC, 
  .operation = ai_sub_f32, 
  .buffer_operation = ai_sub_buffer_f32, 
)

AI_TENSOR_CHAIN_OBJ_DECLARE(
  mul_chain, AI_STATIC_CONST, 4,
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &div_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &mul_output),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 2, &mul_scale, &mul_bias),
  AI_TENSOR_LIST_OBJ_EMPTY
)

AI_LAYER_OBJ_DECLARE(
  mul_layer, 2,
  BN_TYPE, 0x0, NULL,
  bn, forward_bn,
  &mul_chain,
  NULL, &sub_layer, AI_STATIC, 
)

AI_TENSOR_CHAIN_OBJ_DECLARE(
  div_chain, AI_STATIC_CONST, 4,
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 2, &input_output, &val_0_2D),
  AI_TENSOR_LIST_OBJ_INIT(AI_FLAG_NONE, 1, &div_output),
  AI_TENSOR_LIST_OBJ_EMPTY,
  AI_TENSOR_LIST_OBJ_EMPTY
)

AI_LAYER_OBJ_DECLARE(
  div_layer, 1,
  ELTWISE_TYPE, 0x0, NULL,
  eltwise, forward_eltwise,
  &div_chain,
  NULL, &mul_layer, AI_STATIC, 
  .operation = ai_div_f32, 
  .buffer_operation = ai_div_buffer_f32, 
)


#if (AI_TOOLS_API_VERSION < AI_TOOLS_API_VERSION_1_5)

AI_NETWORK_OBJ_DECLARE(
  AI_NET_OBJ_INSTANCE, AI_STATIC,
  AI_BUFFER_INIT(AI_FLAG_NONE,  AI_BUFFER_FORMAT_U8,
    AI_BUFFER_SHAPE_INIT(AI_SHAPE_BCWH, 4, 1, 1050768, 1, 1),
    1050768, NULL, NULL),
  AI_BUFFER_INIT(AI_FLAG_NONE,  AI_BUFFER_FORMAT_U8,
    AI_BUFFER_SHAPE_INIT(AI_SHAPE_BCWH, 4, 1, 27200, 1, 1),
    27200, NULL, NULL),
  AI_TENSOR_LIST_IO_OBJ_INIT(AI_FLAG_NONE, AI_NETWORK_IN_NUM, &input_output),
  AI_TENSOR_LIST_IO_OBJ_INIT(AI_FLAG_NONE, AI_NETWORK_OUT_NUM, &output_output),
  &div_layer, 0x62d22ad3, NULL)

#else

AI_NETWORK_OBJ_DECLARE(
  AI_NET_OBJ_INSTANCE, AI_STATIC,
  AI_BUFFER_ARRAY_OBJ_INIT_STATIC(
  	AI_FLAG_NONE, 1,
    AI_BUFFER_INIT(AI_FLAG_NONE,  AI_BUFFER_FORMAT_U8,
      AI_BUFFER_SHAPE_INIT(AI_SHAPE_BCWH, 4, 1, 1050768, 1, 1),
      1050768, NULL, NULL)
  ),
  AI_BUFFER_ARRAY_OBJ_INIT_STATIC(
  	AI_FLAG_NONE, 1,
    AI_BUFFER_INIT(AI_FLAG_NONE,  AI_BUFFER_FORMAT_U8,
      AI_BUFFER_SHAPE_INIT(AI_SHAPE_BCWH, 4, 1, 27200, 1, 1),
      27200, NULL, NULL)
  ),
  AI_TENSOR_LIST_IO_OBJ_INIT(AI_FLAG_NONE, AI_NETWORK_IN_NUM, &input_output),
  AI_TENSOR_LIST_IO_OBJ_INIT(AI_FLAG_NONE, AI_NETWORK_OUT_NUM, &output_output),
  &div_layer, 0x62d22ad3, NULL)

#endif	/*(AI_TOOLS_API_VERSION < AI_TOOLS_API_VERSION_1_5)*/



/******************************************************************************/
AI_DECLARE_STATIC
ai_bool network_configure_activations(
  ai_network* net_ctx, const ai_network_params* params)
{
  AI_ASSERT(net_ctx)

  if (ai_platform_get_activations_map(g_network_activations_map, 1, params)) {
    /* Updating activations (byte) offsets */
    
    input_output_array.data = AI_PTR(g_network_activations_map[0] + 0);
    input_output_array.data_start = AI_PTR(g_network_activations_map[0] + 0);
    div_output_array.data = AI_PTR(g_network_activations_map[0] + 0);
    div_output_array.data_start = AI_PTR(g_network_activations_map[0] + 0);
    mul_output_array.data = AI_PTR(g_network_activations_map[0] + 4800);
    mul_output_array.data_start = AI_PTR(g_network_activations_map[0] + 4800);
    sub_output_array.data = AI_PTR(g_network_activations_map[0] + 9600);
    sub_output_array.data_start = AI_PTR(g_network_activations_map[0] + 9600);
    conv2d_scratch0_array.data = AI_PTR(g_network_activations_map[0] + 0);
    conv2d_scratch0_array.data_start = AI_PTR(g_network_activations_map[0] + 0);
    conv2d_scratch1_array.data = AI_PTR(g_network_activations_map[0] + 300);
    conv2d_scratch1_array.data_start = AI_PTR(g_network_activations_map[0] + 300);
    conv2d_output_array.data = AI_PTR(g_network_activations_map[0] + 14400);
    conv2d_output_array.data_start = AI_PTR(g_network_activations_map[0] + 14400);
    conv2d_1_scratch0_array.data = AI_PTR(g_network_activations_map[0] + 0);
    conv2d_1_scratch0_array.data_start = AI_PTR(g_network_activations_map[0] + 0);
    conv2d_1_scratch1_array.data = AI_PTR(g_network_activations_map[0] + 3200);
    conv2d_1_scratch1_array.data_start = AI_PTR(g_network_activations_map[0] + 3200);
    conv2d_1_output_array.data = AI_PTR(g_network_activations_map[0] + 9280);
    conv2d_1_output_array.data_start = AI_PTR(g_network_activations_map[0] + 9280);
    _unsafe_view_to_chlast_output_array.data = AI_PTR(g_network_activations_map[0] + 0);
    _unsafe_view_to_chlast_output_array.data_start = AI_PTR(g_network_activations_map[0] + 0);
    linear_output_array.data = AI_PTR(g_network_activations_map[0] + 6400);
    linear_output_array.data_start = AI_PTR(g_network_activations_map[0] + 6400);
    relu_2_output_array.data = AI_PTR(g_network_activations_map[0] + 0);
    relu_2_output_array.data_start = AI_PTR(g_network_activations_map[0] + 0);
    output_output_array.data = AI_PTR(g_network_activations_map[0] + 2048);
    output_output_array.data_start = AI_PTR(g_network_activations_map[0] + 2048);
    return true;
  }
  AI_ERROR_TRAP(net_ctx, INIT_FAILED, NETWORK_ACTIVATIONS);
  return false;
}




/******************************************************************************/
AI_DECLARE_STATIC
ai_bool network_configure_weights(
  ai_network* net_ctx, const ai_network_params* params)
{
  AI_ASSERT(net_ctx)

  if (ai_platform_get_weights_map(g_network_weights_map, 1, params)) {
    /* Updating weights (byte) offsets */
    
    val_0_2D_array.format |= AI_FMT_FLAG_CONST;
    val_0_2D_array.data = AI_PTR(g_network_weights_map[0] + 0);
    val_0_2D_array.data_start = AI_PTR(g_network_weights_map[0] + 0);
    val_2_2D_array.format |= AI_FMT_FLAG_CONST;
    val_2_2D_array.data = AI_PTR(g_network_weights_map[0] + 4);
    val_2_2D_array.data_start = AI_PTR(g_network_weights_map[0] + 4);
    mul_scale_array.format |= AI_FMT_FLAG_CONST;
    mul_scale_array.data = AI_PTR(g_network_weights_map[0] + 8);
    mul_scale_array.data_start = AI_PTR(g_network_weights_map[0] + 8);
    mul_bias_array.format |= AI_FMT_FLAG_CONST;
    mul_bias_array.data = AI_PTR(g_network_weights_map[0] + 4808);
    mul_bias_array.data_start = AI_PTR(g_network_weights_map[0] + 4808);
    conv2d_weights_array.format |= AI_FMT_FLAG_CONST;
    conv2d_weights_array.data = AI_PTR(g_network_weights_map[0] + 9608);
    conv2d_weights_array.data_start = AI_PTR(g_network_weights_map[0] + 9608);
    conv2d_bias_array.format |= AI_FMT_FLAG_CONST;
    conv2d_bias_array.data = AI_PTR(g_network_weights_map[0] + 19208);
    conv2d_bias_array.data_start = AI_PTR(g_network_weights_map[0] + 19208);
    conv2d_1_weights_array.format |= AI_FMT_FLAG_CONST;
    conv2d_1_weights_array.data = AI_PTR(g_network_weights_map[0] + 19336);
    conv2d_1_weights_array.data_start = AI_PTR(g_network_weights_map[0] + 19336);
    conv2d_1_bias_array.format |= AI_FMT_FLAG_CONST;
    conv2d_1_bias_array.data = AI_PTR(g_network_weights_map[0] + 224136);
    conv2d_1_bias_array.data_start = AI_PTR(g_network_weights_map[0] + 224136);
    linear_weights_array.format |= AI_FMT_FLAG_CONST;
    linear_weights_array.data = AI_PTR(g_network_weights_map[0] + 225416);
    linear_weights_array.data_start = AI_PTR(g_network_weights_map[0] + 224392);
    linear_bias_array.format |= AI_FMT_FLAG_CONST;
    linear_bias_array.data = AI_PTR(g_network_weights_map[0] + 1044616);
    linear_bias_array.data_start = AI_PTR(g_network_weights_map[0] + 1044616);
    output_weights_array.format |= AI_FMT_FLAG_CONST;
    output_weights_array.data = AI_PTR(g_network_weights_map[0] + 1046664);
    output_weights_array.data_start = AI_PTR(g_network_weights_map[0] + 1046664);
    output_bias_array.format |= AI_FMT_FLAG_CONST;
    output_bias_array.data = AI_PTR(g_network_weights_map[0] + 1050760);
    output_bias_array.data_start = AI_PTR(g_network_weights_map[0] + 1050760);
    return true;
  }
  AI_ERROR_TRAP(net_ctx, INIT_FAILED, NETWORK_WEIGHTS);
  return false;
}


/**  PUBLIC APIs SECTION  *****************************************************/



AI_DEPRECATED
AI_API_ENTRY
ai_bool ai_network_get_info(
  ai_handle network, ai_network_report* report)
{
  ai_network* net_ctx = AI_NETWORK_ACQUIRE_CTX(network);

  if (report && net_ctx)
  {
    ai_network_report r = {
      .model_name        = AI_NETWORK_MODEL_NAME,
      .model_signature   = AI_NETWORK_MODEL_SIGNATURE,
      .model_datetime    = AI_TOOLS_DATE_TIME,
      
      .compile_datetime  = AI_TOOLS_COMPILE_TIME,
      
      .runtime_revision  = ai_platform_runtime_get_revision(),
      .runtime_version   = ai_platform_runtime_get_version(),

      .tool_revision     = AI_TOOLS_REVISION_ID,
      .tool_version      = {AI_TOOLS_VERSION_MAJOR, AI_TOOLS_VERSION_MINOR,
                            AI_TOOLS_VERSION_MICRO, 0x0},
      .tool_api_version  = AI_STRUCT_INIT,

      .api_version            = ai_platform_api_get_version(),
      .interface_api_version  = ai_platform_interface_api_get_version(),
      
      .n_macc            = 6950146,
      .n_inputs          = 0,
      .inputs            = NULL,
      .n_outputs         = 0,
      .outputs           = NULL,
      .params            = AI_STRUCT_INIT,
      .activations       = AI_STRUCT_INIT,
      .n_nodes           = 0,
      .signature         = 0x62d22ad3,
    };

    if (!ai_platform_api_get_network_report(network, &r)) return false;

    *report = r;
    return true;
  }
  return false;
}



AI_API_ENTRY
ai_bool ai_network_get_report(
  ai_handle network, ai_network_report* report)
{
  ai_network* net_ctx = AI_NETWORK_ACQUIRE_CTX(network);

  if (report && net_ctx)
  {
    ai_network_report r = {
      .model_name        = AI_NETWORK_MODEL_NAME,
      .model_signature   = AI_NETWORK_MODEL_SIGNATURE,
      .model_datetime    = AI_TOOLS_DATE_TIME,
      
      .compile_datetime  = AI_TOOLS_COMPILE_TIME,
      
      .runtime_revision  = ai_platform_runtime_get_revision(),
      .runtime_version   = ai_platform_runtime_get_version(),

      .tool_revision     = AI_TOOLS_REVISION_ID,
      .tool_version      = {AI_TOOLS_VERSION_MAJOR, AI_TOOLS_VERSION_MINOR,
                            AI_TOOLS_VERSION_MICRO, 0x0},
      .tool_api_version  = AI_STRUCT_INIT,

      .api_version            = ai_platform_api_get_version(),
      .interface_api_version  = ai_platform_interface_api_get_version(),
      
      .n_macc            = 6950146,
      .n_inputs          = 0,
      .inputs            = NULL,
      .n_outputs         = 0,
      .outputs           = NULL,
      .map_signature     = AI_MAGIC_SIGNATURE,
      .map_weights       = AI_STRUCT_INIT,
      .map_activations   = AI_STRUCT_INIT,
      .n_nodes           = 0,
      .signature         = 0x62d22ad3,
    };

    if (!ai_platform_api_get_network_report(network, &r)) return false;

    *report = r;
    return true;
  }
  return false;
}


AI_API_ENTRY
ai_error ai_network_get_error(ai_handle network)
{
  return ai_platform_network_get_error(network);
}


AI_API_ENTRY
ai_error ai_network_create(
  ai_handle* network, const ai_buffer* network_config)
{
  return ai_platform_network_create(
    network, network_config, 
    AI_CONTEXT_OBJ(&AI_NET_OBJ_INSTANCE),
    AI_TOOLS_API_VERSION_MAJOR, AI_TOOLS_API_VERSION_MINOR, AI_TOOLS_API_VERSION_MICRO);
}


AI_API_ENTRY
ai_error ai_network_create_and_init(
  ai_handle* network, const ai_handle activations[], const ai_handle weights[])
{
  ai_error err;
  ai_network_params params;

  err = ai_network_create(network, AI_NETWORK_DATA_CONFIG);
  if (err.type != AI_ERROR_NONE) {
    return err;
  }
  
  if (ai_network_data_params_get(&params) != true) {
    err = ai_network_get_error(*network);
    return err;
  }
#if defined(AI_NETWORK_DATA_ACTIVATIONS_COUNT)
  /* set the addresses of the activations buffers */
  for (ai_u16 idx=0; activations && idx<params.map_activations.size; idx++) {
    AI_BUFFER_ARRAY_ITEM_SET_ADDRESS(&params.map_activations, idx, activations[idx]);
  }
#endif
#if defined(AI_NETWORK_DATA_WEIGHTS_COUNT)
  /* set the addresses of the weight buffers */
  for (ai_u16 idx=0; weights && idx<params.map_weights.size; idx++) {
    AI_BUFFER_ARRAY_ITEM_SET_ADDRESS(&params.map_weights, idx, weights[idx]);
  }
#endif
  if (ai_network_init(*network, &params) != true) {
    err = ai_network_get_error(*network);
  }
  return err;
}


AI_API_ENTRY
ai_buffer* ai_network_inputs_get(ai_handle network, ai_u16 *n_buffer)
{
  if (network == AI_HANDLE_NULL) {
    network = (ai_handle)&AI_NET_OBJ_INSTANCE;
    AI_NETWORK_OBJ(network)->magic = AI_MAGIC_CONTEXT_TOKEN;
  }
  return ai_platform_inputs_get(network, n_buffer);
}


AI_API_ENTRY
ai_buffer* ai_network_outputs_get(ai_handle network, ai_u16 *n_buffer)
{
  if (network == AI_HANDLE_NULL) {
    network = (ai_handle)&AI_NET_OBJ_INSTANCE;
    AI_NETWORK_OBJ(network)->magic = AI_MAGIC_CONTEXT_TOKEN;
  }
  return ai_platform_outputs_get(network, n_buffer);
}


AI_API_ENTRY
ai_handle ai_network_destroy(ai_handle network)
{
  return ai_platform_network_destroy(network);
}


AI_API_ENTRY
ai_bool ai_network_init(
  ai_handle network, const ai_network_params* params)
{
  ai_network* net_ctx = AI_NETWORK_OBJ(ai_platform_network_init(network, params));
  ai_bool ok = true;

  if (!net_ctx) return false;
  ok &= network_configure_weights(net_ctx, params);
  ok &= network_configure_activations(net_ctx, params);

  ok &= ai_platform_network_post_init(network);

  return ok;
}


AI_API_ENTRY
ai_i32 ai_network_run(
  ai_handle network, const ai_buffer* input, ai_buffer* output)
{
  return ai_platform_network_process(network, input, output);
}


AI_API_ENTRY
ai_i32 ai_network_forward(ai_handle network, const ai_buffer* input)
{
  return ai_platform_network_process(network, input, NULL);
}



#undef AI_NETWORK_MODEL_SIGNATURE
#undef AI_NET_OBJ_INSTANCE
#undef AI_TOOLS_DATE_TIME
#undef AI_TOOLS_COMPILE_TIME

