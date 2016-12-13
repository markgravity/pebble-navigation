#include <pebble.h>
#include <pebble-fctx/fctx.h>
#include <pebble-fctx/fpath.h>
#include <pebble-fctx/ffont.h>
#include "utils.h"
// --------------------------------------------------------------------------
// Types and global variables.
// --------------------------------------------------------------------------

#define RESMEM 1

Window* _window;
Layer* _drawingLayer;
TextLayer* _distanceToTurnTextLayer;
TextLayer* _distanceToTurnUnitTextLayer;
Layer* _bottomLayer;
GColor _bottomLayerColor;
int _directionDegree;

static AppSync _appSync;
static uint8_t _appSyncBuffer[128];

#if RESMEM
void* _resourceMemory;
#endif

FPath* _arrowStraight;
FPath* _arrowTurnLeft;
FPath* _arrowTurnRight;
FPath* _currentDirectionPath;
typedef enum {
  DirectionTypeStraight = 12,
  DirectionTypeTurnLeft = 8,
  DirectionTypeTurnRight = 10
} DirectionType;

typedef enum {
  NavigationStatusInRoute = 0,
  NavigationStatusWrongWay = 1,
  NavigationStatusNearly = 2
} NavigationStatus;

typedef enum {
  MKEY_DirectionType = 0,
  MKEY_DistanceToNextTurn = 1,
  MKEY_DistanceUnitText = 2,
  MKEY_DistanceToNotify = 3,
  MKEY_NavigationStatus = 4,
  MKEY_DirectionDegree = 5,
} MKEY;

const int inbox_size = 128;
const int outbox_size = 128;
int is_initialize_views = 0;
// --------------------------------------------------------------------------
// Functions
// --------------------------------------------------------------------------
void change_direction(DirectionType direction){
  switch (direction) {
    case DirectionTypeTurnLeft:
      _currentDirectionPath = _arrowTurnLeft;
      break;

    case DirectionTypeTurnRight:
        _currentDirectionPath = _arrowTurnRight;
        break;
    case DirectionTypeStraight:
    default:
        _currentDirectionPath = _arrowStraight;
  }

  layer_mark_dirty(_drawingLayer);
}
void change_direction_degree(int degree){
  _directionDegree = degree;

  layer_mark_dirty(_drawingLayer);
}
void change_navigation_status(NavigationStatus status){
  switch (status) {
    case NavigationStatusInRoute:
      _bottomLayerColor = GColorJaegerGreen;
      break;

    case NavigationStatusNearly:
        _bottomLayerColor = GColorElectricUltramarine;
        break;
    case NavigationStatusWrongWay:
    default:
        _bottomLayerColor = GColorFolly;
  }

  layer_mark_dirty(_bottomLayer);
}


// --------------------------------------------------------------------------
// Drawing Processing
// --------------------------------------------------------------------------
void on_drawing_layer_update(Layer* layer, GContext* ctx){
  if (! _currentDirectionPath) return;

  GRect layerFrame = layer_get_frame(layer);
  FPoint center = FPointI(layerFrame.size.w / 2, layerFrame.size.h / 2);
  FContext fctx;
  fctx_init_context(&fctx, ctx);
  fctx_set_color_bias(&fctx, 0);

  // drawing arrow-straight
  FPoint pivot;
  if (_currentDirectionPath == _arrowStraight) {
      pivot = FPointI(21, 88);
  } else if (_currentDirectionPath == _arrowTurnLeft) {
      pivot = FPointI(59, 81);
  } else if (_currentDirectionPath == _arrowTurnRight) {
      pivot = FPointI(10, 81);
  }

  fctx_set_pivot(&fctx, pivot);
  fctx_set_offset(&fctx, FPointI(layerFrame.size.w / 2, (layerFrame.size.h / 2) + 17));

  fctx_begin_fill(&fctx);
  fctx_set_fill_color(&fctx, GColorDarkGray);
  fctx_set_rotation(&fctx, rad(_directionDegree));
  fctx_draw_commands(&fctx, FPointZero, _currentDirectionPath->data, _currentDirectionPath->size);
  fctx_end_fill(&fctx);

  fctx_deinit_context(&fctx);
}
void on_drawing_bottom_layer_update(Layer* layer, GContext* ctx){
  graphics_context_set_fill_color(ctx, _bottomLayerColor);
  graphics_fill_rect(ctx, layer_get_bounds(layer), 0, GCornerNone);
}

// --------------------------------------------------------------------------
// Animation
// --------------------------------------------------------------------------
void animation_start(){
  Layer* windowLayer = window_get_root_layer(_window);
  GRect windowFrame = layer_get_frame(windowLayer);

  GRect start = GRect(0, windowFrame.size.h, windowFrame.size.w, 1);
  GRect finish = GRect(0, windowFrame.size.h - 60, windowFrame.size.w, 60);
  PropertyAnimation *prop_anim = property_animation_create_layer_frame(_bottomLayer,
                                                               &start, &finish);

  Animation *anim = property_animation_get_animation(prop_anim);

  // Choose parameters
  const int delay_ms = 500;
  const int duration_ms = 500;

  // Configure the Animation's curve, delay, and duration
  animation_set_curve(anim, AnimationCurveEaseOut);
  animation_set_delay(anim, delay_ms);
  animation_set_duration(anim, duration_ms);
  animation_schedule(anim);
}
// --------------------------------------------------------------------------
// Creating Views
// --------------------------------------------------------------------------
void init_views(){
  Layer* windowLayer = window_get_root_layer(_window);
  GRect windowFrame = layer_get_frame(windowLayer);

  // init bottom Layer
  _bottomLayer = layer_create(GRectZero);
  layer_set_update_proc(_bottomLayer, on_drawing_bottom_layer_update);
  layer_add_child(windowLayer, _bottomLayer);

  // init Drawing Layer
  _drawingLayer = layer_create(windowFrame);
  layer_set_update_proc(_drawingLayer, on_drawing_layer_update);
  layer_add_child(windowLayer, _drawingLayer);

  // init distanceToTurn Text Layer
  GRect distanceToTurnFrame = GRect(0, windowFrame.size.h - 60, windowFrame.size.w, 45);
  _distanceToTurnTextLayer = text_layer_create(distanceToTurnFrame);
  text_layer_set_text_alignment(_distanceToTurnTextLayer, GTextAlignmentCenter);
  text_layer_set_text_color(_distanceToTurnTextLayer, GColorWhite);
  text_layer_set_background_color(_distanceToTurnTextLayer, GColorClear);
  text_layer_set_font(_distanceToTurnTextLayer, fonts_get_system_font(FONT_KEY_LECO_36_BOLD_NUMBERS));
  text_layer_set_text(_distanceToTurnTextLayer, "100");
  layer_add_child(windowLayer, text_layer_get_layer(_distanceToTurnTextLayer));

  // init distanceToTurnUnitTextLayer Text Layer
  GRect distanceToTurnUnitFrame = GRect(0, windowFrame.size.h - 30, windowFrame.size.w, 48);
  _distanceToTurnUnitTextLayer = text_layer_create(distanceToTurnUnitFrame);
  text_layer_set_text_alignment(_distanceToTurnUnitTextLayer, GTextAlignmentCenter);
  text_layer_set_text_color(_distanceToTurnUnitTextLayer, GColorWhite);
  text_layer_set_background_color(_distanceToTurnUnitTextLayer, GColorClear);
  text_layer_set_font(_distanceToTurnUnitTextLayer, fonts_get_system_font(FONT_KEY_GOTHIC_24_BOLD));
  text_layer_set_text(_distanceToTurnUnitTextLayer, "km");
  layer_add_child(windowLayer, text_layer_get_layer(_distanceToTurnUnitTextLayer));

  animation_start();

}

// --------------------------------------------------------------------------
// App Message
// --------------------------------------------------------------------------
static void inbox_received_callback(DictionaryIterator *iterator, void *context) {
  Tuple *direction_type_tuple = dict_find(iterator, MESSAGE_KEY_DirectionType);
  Tuple *distance_next_turn_tuple = dict_find(iterator, MESSAGE_KEY_DistanceToNextTurn);
  Tuple *distance_unit_text_tuple = dict_find(iterator, MESSAGE_KEY_DistanceUnitText);

  if (direction_type_tuple
    && distance_next_turn_tuple
    && distance_unit_text_tuple) {

      // init views for the first time received messages
      if (is_initialize_views == 0)
          init_views();

      DirectionType direction = direction_type_tuple->value->int32;
      change_direction(direction);
      text_layer_set_text(_distanceToTurnTextLayer, distance_next_turn_tuple->value->cstring);
      text_layer_set_text(_distanceToTurnUnitTextLayer, distance_unit_text_tuple->value->cstring);
    }

}
static void inbox_dropped_callback(AppMessageResult reason, void *context) {
  APP_LOG(APP_LOG_LEVEL_ERROR, "Message dropped!");
}

static void outbox_failed_callback(DictionaryIterator *iterator, AppMessageResult reason, void *context) {
  APP_LOG(APP_LOG_LEVEL_ERROR, "Outbox send failed!");
}

static void outbox_sent_callback(DictionaryIterator *iterator, void *context) {
  APP_LOG(APP_LOG_LEVEL_INFO, "Outbox send success!");
}

void init_app_message(){
  // Register callbacks
  app_message_register_inbox_received(inbox_received_callback);
  app_message_register_inbox_dropped(inbox_dropped_callback);
  app_message_register_outbox_failed(outbox_failed_callback);
  app_message_register_outbox_sent(outbox_sent_callback);

  // Open AppMessage
  app_message_open(inbox_size, outbox_size);
}

static void sync_error_callback(DictionaryResult dict_error, AppMessageResult app_message_error, void *context) {
  APP_LOG(APP_LOG_LEVEL_DEBUG, "App Message Sync Error: %d", app_message_error);
}

static void sync_tuple_changed_callback(const uint32_t key, const Tuple* new_tuple, const Tuple* old_tuple, void* context) {
APP_LOG(APP_LOG_LEVEL_DEBUG, "received");
  // init views for the first time received messages
  if (is_initialize_views == 0) {
    is_initialize_views = 1;
    init_views();
  }


  switch (key) {
    case MKEY_DirectionType:
      change_direction(new_tuple->value->int32);
      break;

    case MKEY_DistanceToNextTurn:
      text_layer_set_text(_distanceToTurnTextLayer, new_tuple->value->cstring);
      break;

    case MKEY_DistanceUnitText:
      text_layer_set_text(_distanceToTurnUnitTextLayer, new_tuple->value->cstring);
      break;

    case MKEY_NavigationStatus:
        change_navigation_status(new_tuple->value->int32);
        break;

    case MKEY_DirectionDegree:
        change_direction_degree(new_tuple->value->int32);

  }
}

void init_app_sync(){
  Tuplet initialValues[] = {
    TupletInteger(MKEY_DirectionType, (uint8_t) 0),
    TupletCString(MKEY_DistanceToNextTurn, "0"),
    TupletCString(MKEY_DistanceUnitText, "m"),
    TupletInteger(MKEY_NavigationStatus, (uint8_t) NavigationStatusInRoute),
    TupletInteger(MKEY_DirectionDegree, (uint8_t) 0)
  };

  app_sync_init(&_appSync, _appSyncBuffer, sizeof(_appSyncBuffer),
      initialValues, ARRAY_LENGTH(initialValues),
      sync_tuple_changed_callback, sync_error_callback, NULL
  );

  app_message_open(inbox_size, outbox_size);
}
// --------------------------------------------------------------------------
// Loading resources.
// --------------------------------------------------------------------------

void load_resources(){
  size_t arrowStraightSize = resource_size(resource_get_handle(RESOURCE_ID_ARROW_STRAIGHT_FPATH));
  size_t arrowTurnLeftSize = sizeof(FPath) + resource_size(resource_get_handle(RESOURCE_ID_ARROW_TURN_LEFT_FPATH));
  size_t arrowTurnRightSize = sizeof(FPath) + resource_size(resource_get_handle(RESOURCE_ID_ARROW_TURN_RIGHT_FPATH));

  size_t resourceSize = arrowStraightSize + arrowTurnLeftSize + arrowTurnRightSize;
  void* _resourceMemory = malloc(resourceSize);
  void* resptr = _resourceMemory;

  _arrowStraight = fpath_load_from_resource_into_buffer(RESOURCE_ID_ARROW_STRAIGHT_FPATH, resptr);
  resptr += arrowStraightSize;

  _arrowTurnLeft = fpath_load_from_resource_into_buffer(RESOURCE_ID_ARROW_TURN_LEFT_FPATH, resptr);
  resptr += arrowTurnLeftSize;

  _arrowTurnRight = fpath_load_from_resource_into_buffer(RESOURCE_ID_ARROW_TURN_RIGHT_FPATH, resptr);
  resptr += arrowTurnRightSize;
}

// --------------------------------------------------------------------------
// Init
// --------------------------------------------------------------------------
void init(){
  _window = window_create();
  window_set_background_color(_window, GColorWhite);
  window_stack_push(_window, true);

  init_app_sync();
}

// --------------------------------------------------------------------------
// Deadloc
// --------------------------------------------------------------------------
static void deinit() {
    window_destroy(_window);
    layer_destroy(_drawingLayer);
    text_layer_destroy(_distanceToTurnTextLayer);
    text_layer_destroy(_distanceToTurnUnitTextLayer);
    free(_resourceMemory);
}

int main(void) {
  load_resources();
  init();

  app_event_loop();
  deinit();
}
