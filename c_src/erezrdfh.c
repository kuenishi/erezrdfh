#include <erl_nif.h>
#include <string.h>
#define EREZRDFH_QUEUE_ARRAY_SIZE (1024)

struct erezrdfh_list_t_ {
  size_t size;
  char*  binary;
  struct erezrdfh_list_t_* next;
};

typedef struct erezrdfh_list_t_ erezrdfh_list_t;

erezrdfh_list_t* erezrdfh_list_push(size_t s, const char* bin,
                                    erezrdfh_list_t* list)
{
  erezrdfh_list_t* ret = (erezrdfh_list_t*)malloc(sizeof(erezrdfh_list_t));
  ret->size = s;
  ret->binary = (char*)malloc(sizeof(char)*s);
  memcpy(ret->binary, bin, s);
  ret->next = list;
  return ret;
}

erezrdfh_list_t* erezrdfh_list_pop(erezrdfh_list_t* list,
                                   char** bin, size_t* s)
{
  if(list == NULL) return NULL;

  erezrdfh_list_t* ret = list->next;
  *bin = list->binary;
  *s = list->size;
  free(list);
  return ret;
}
erezrdfh_list_t* erezrdfh_list_new(void){
  return NULL;
}
void erezrdfh_list_free(erezrdfh_list_t* list){
  erezrdfh_list_t* cur = list;
  while(cur != NULL){
    char* bin;
    size_t s;
    cur = erezrdfh_list_pop(cur, &bin, &s);
    free(bin);
  }
}

typedef struct {
  char name[256];
  erezrdfh_list_t* back;
  ErlNifMutex *back_lock;
  erezrdfh_list_t* front;
  ErlNifMutex *front_lock;
  char used;
} erezrdfh_queue_t;

void erezrdfh_queue_init(erezrdfh_queue_t* q, const char* n){
  strncpy(q->name, n, 255);
  q->back = erezrdfh_list_new();
  q->back_lock = enif_mutex_create("back_lock");
  q->front = erezrdfh_list_new();
  q->front_lock = enif_mutex_create("front_lock");
  q->used = q->name[0];
}
void erezrdfh_queue_fini(erezrdfh_queue_t* q){
  erezrdfh_list_free(q->back);
  enif_mutex_destroy(q->back_lock);
  erezrdfh_list_free(q->front);
  enif_mutex_destroy(q->front_lock);
  q->used = 0;
}

typedef struct {
  // rwlock to control
  ErlNifRWLock * rwlock;
  // fixed size array of queues
  erezrdfh_queue_t q_array[EREZRDFH_QUEUE_ARRAY_SIZE];
  // memory pool
  // erezrdfh_memory_pool pool;
} erezrdfh_queue_array_t;

void erezrdfh_queue_array_init(erezrdfh_queue_array_t* arr){
  size_t s;
  arr->rwlock = enif_rwlock_create(__FILE__);
  for(s=0; s<EREZRDFH_QUEUE_ARRAY_SIZE; ++s){
    arr->q_array[s].used = 0;
  }
}

void erezrdfh_queue_array_fini(erezrdfh_queue_array_t* arr){
  size_t s;
  for(s=0; s<EREZRDFH_QUEUE_ARRAY_SIZE; ++s){
    if(arr->q_array[s].used){
      erezrdfh_queue_fini(&(arr->q_array[s]));
    }
  }
  enif_rwlock_destroy(arr->rwlock);
}

static inline ERL_NIF_TERM erezrdfh_error_reason(ErlNifEnv* env,
                                                ERL_NIF_TERM reason)
{
  ERL_NIF_TERM e;
  enif_make_existing_atom(env, "error", &e, ERL_NIF_LATIN1);
  return enif_make_tuple2(env, e, reason);
}
static inline ERL_NIF_TERM erezrdfh_error_tuple(ErlNifEnv* env, const char* atom)
{
  ERL_NIF_TERM v = enif_make_atom(env, atom);
  return erezrdfh_error_reason(env, v);
}
static inline ERL_NIF_TERM erezrdfh_make_badarg(ErlNifEnv* env,
                                               ERL_NIF_TERM badarg)
{
  ERL_NIF_TERM v = enif_make_atom(env, "badarg");
  return erezrdfh_error_reason(env, enif_make_tuple2(env, v, badarg));
}

ERL_NIF_TERM erezrdfh_new_queue(ErlNifEnv* env, int argc,
                                const ERL_NIF_TERM argv[]){
  size_t s;
  ErlNifBinary given_name;
  if(! enif_inspect_binary(env, argv[0], &given_name)){
    return erezrdfh_make_badarg(env, argv[0]);
  }
  if( given_name.size == 0 ){
    return erezrdfh_error_tuple(env, "empty_name");
  }
  if( given_name.data[0] == '\0' ){ //empty string ""
    return erezrdfh_error_tuple(env, "empty_name");
  }
  erezrdfh_queue_array_t* qa = (erezrdfh_queue_array_t*)enif_priv_data(env);
  enif_rwlock_rwlock(qa->rwlock);
  for(s=0; s<EREZRDFH_QUEUE_ARRAY_SIZE; ++s){
    if(qa->q_array[s].used == given_name.data[0]){
      enif_rwlock_rwunlock(qa->rwlock);
      return erezrdfh_error_tuple(env, "already_exists");
    }
  }
  for(s=0; s<EREZRDFH_QUEUE_ARRAY_SIZE; ++s){
    if(qa->q_array[s].used == 0){
      erezrdfh_queue_init(&(qa->q_array[s]), (char*)given_name.data);
      enif_rwlock_rwunlock(qa->rwlock);
      return enif_make_atom(env, "ok");
    }
  }
  enif_rwlock_rwunlock(qa->rwlock);
  return erezrdfh_error_tuple(env, "array_full");
}
ERL_NIF_TERM erezrdfh_del_queue(ErlNifEnv* env, int argc,
                                const ERL_NIF_TERM argv[]){
  return enif_make_atom(env, "okeee");
}
ERL_NIF_TERM erezrdfh_push(ErlNifEnv* env, int argc,
                           const ERL_NIF_TERM argv[]){
  return enif_make_atom(env, "okeee");
}
ERL_NIF_TERM erezrdfh_pop(ErlNifEnv* env, int argc,
                           const ERL_NIF_TERM argv[]){
  return enif_make_atom(env, "okeee");
}


static int erezrdfh_nif_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info)
{
  erezrdfh_queue_array_t* qa;
  qa = (erezrdfh_queue_array_t*)enif_alloc(sizeof(erezrdfh_queue_array_t));
  erezrdfh_queue_array_init(qa);
  *priv_data = qa;
  return 0;
}

static int erezrdfh_nif_upgrade(ErlNifEnv* env, void** priv_data,
                               void** old_priv_data, ERL_NIF_TERM load_info){
  *priv_data = old_priv_data;
  return 0;
}

static void erezrdfh_nif_unload(ErlNifEnv* env, void* priv_data)
{
  erezrdfh_queue_array_t* qa = (erezrdfh_queue_array_t*)priv_data;
  erezrdfh_queue_array_fini(qa);
  enif_free((void*)qa);
}

static ErlNifFunc erezrdfh_nif_funcs[] = {
  {"new_queue", 1, erezrdfh_new_queue},
  {"del_queue", 1, erezrdfh_del_queue},
  {"push", 2, erezrdfh_push},
  {"pop", 1, erezrdfh_pop}
};

ERL_NIF_INIT(erezrdfh_queue_nif,
             erezrdfh_nif_funcs,
             erezrdfh_nif_load, //load
             NULL, //reload
             erezrdfh_nif_upgrade,
             erezrdfh_nif_unload) //unload
