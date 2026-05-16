#ifndef AI_BENCHMARK_H
#define AI_BENCHMARK_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef AI_BENCHMARK_MODE

void ai_benchmark_task_init(void);
void ai_benchmark_task(void *param);

#endif

#ifdef __cplusplus
}
#endif

#endif
