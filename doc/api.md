# **1. User Api**
--------

### **Signin**

**POST** [api/session](api/session)

**Param request:**

  * `email`, type: string, presence: true
  * `password`, type: string, presence: true

**Request example:**

  * `POST: {"user": {"email": "hoang.thi.nhung@framgia.com", "password": "12345678"}}`

**Response:** (Return json with user's information if success else return json with error message)

  * SUCCESS:

    `{"message": "Login Success!", "user": {"id": 1, "name": "Hoang Thi Nhung", "email": "hoang.thi.nhung@framgia.com", "avatar": null, "chatwork_id": null, "token": null, "uid": null, "provider": null, "expires_at": null, "refresh_token": null, "email_require": false, "created_at": "2016-07-27T05:59:21.000Z", "updated_at": "2016-08-04T02:56:54.348Z", "auth_token": "QNoUsPX4BVQqU_zAs3VF", "user_calendars": [{"id": 1, "user_id": 1, "calendar_id": 1, "permission_id": 1, "color_id": 8, "created_at": "2016-07-27T05:59:22.000Z", "updated_at": "2016-08-04T02:18:20.000Z"}], "shared_calendars": [{"id": 1, "user_id": 1, "name": "Hoang Thi Nhung", "description": null, "color_id": 10, "status": "no_public", "is_default": true, "created_at": "2016-07-27T05:59:22.000Z", "updated_at": "2016-07-27T05:59:22.000Z"}]}}`

  * FAILS:

    `{"error": "Invalid email or password"}`


# **2. Event Api**
---------

### **List Event**

**GET** [api/events](api/events)

**Param request:**

  * `auth_token`, type: string, presence: true (example: `:auth_token`)
  * `calendars`, type: string

**Response:**

  * SUCCESS:

    `{"message": "Request Success!",
      "events": [
        {
          "id": "NDctMjAxNi0wOC0wNFQxMDozMDowMCswMDowMA==\n",
          "title": "Framgia CRB Meeting",
          "start_date": "2016-08-04 10:30",
          "finish_date": "2016-08-04 12:30",
          "start_repeat": "2016-08-04",
          "end_repeat": "2016-08-07",
          "color_id": 8,
          "calendar": "Hoang Thi Nhung",
          "calendar_id": 1,
          "all_day": false,
          "repeat_type": "weekly",
          "exception_type": null,
          "event_id": 47,
          "exception_time": null,
          "editable": true,
          "persisted": true,
          "event": {
            "id": 47,
            "title": "Framgia CRB Meeting",
            "description": "CRB meeting",
            "status": null,
            "color": null,
            "all_day": false,
            "repeat_type": "weekly",
            "repeat_every": 1,
            "user_id": 1,
            "calendar_id": 1,
            "start_date": "2016-08-04T10:30:00.000Z",
            "finish_date": "2016-08-04T12:30:00.000Z",
            "start_repeat": "2016-08-04T00:00:00.000Z",
            "end_repeat": "2016-08-07T00:00:00.000Z",
            "exception_time": null,
            "exception_type": null,
            "old_exception_type": null,
            "parent_id": null,
            "chatwork_room_id": null,
            "task_content": null,
            "message_content": null,
            "google_event_id": null,
            "google_calendar_id": null,
            "created_at": "2016-08-04T04:12:47.000Z",
            "updated_at": "2016-08-04T04:12:47.000Z",
            "deleted_at": null
          },
          "attendees": [
            {
              "id": 15,
              "email": "chu.anh.tuan@framgia.com",
              "user_id": 3,
              "event_id": 47,
              "created_at": "2016-08-04T04:12:47.000Z",
              "updated_at": "2016-08-04T04:12:47.000Z"
            }
          ],
          "repeat_ons": [
            {
              "id": 40,
              "event_id": 47,
              "days_of_week_id": 5,
              "created_at": "2016-08-04T04:12:47.000Z",
              "updated_at": "2016-08-04T04:12:47.000Z"
            }
          ],
          "days_of_weeks": [
            {
              "id": 5,
              "name": "th",
              "created_at": "2016-07-27T05:59:21.000Z",
              "updated_at": "2016-07-27T05:59:21.000Z"
            }
          ],
          "notification_events": [
            {
              "id": 9,
              "event_id": 47,
              "notification_id": 1,
              "created_at": "2016-08-04T04:12:47.000Z",
              "updated_at": "2016-08-04T04:12:47.000Z"
            }
          ],
          "notifications": [
            {
              "id": 1,
              "notification_type": "Email",
              "created_at": "2016-07-27T05:59:19.000Z",
              "updated_at": "2016-07-27T05:59:19.000Z"
            }
          ],
          "owner": {
            "id": 1,
            "name": "Hoang Thi Nhung",
            "email": "hoang.thi.nhung@framgia.com",
            "avatar": null,
            "chatwork_id": null,
            "google_calendar_id": "82poim9ul05t12pg4cc0u0hnvo@group.calendar.google.com",
            "token": null,
            "uid": null,
            "provider": null,
            "expires_at": null,
            "refresh_token": null,
            "email_require": false,
            "created_at": "2016-07-27T05:59:21.000Z",
            "updated_at": "2016-08-04T02:56:54.000Z",
            "auth_token": "QNoUsPX4BVQqU_zAs3VF"
          }
        }
      ]
    }`

  * FAILS:

    `{"error": "Invalid Params"}`

### **Show Event**

**GET** [api/events/:event_id.json](api/events/:event_id.json)

**Param Request:**

  * `auth_token`, type: string, presence: true (example: `:auth_token`)

**Response:**

  * SUCCESS:

    `{"message": "Show Detail Event Success!",
      "event": {
        "id": 154,
        "title": "abc",
        "description": "",
        "status": null,
        "color": null,
        "all_day": true,
        "repeat_type": "daily",
        "repeat_every": 1,
        "user_id": 6,
        "calendar_id": 6,
        "start_date": "2016-07-28T00:00:00.000Z",
        "finish_date": "2016-07-28T23:59:00.000Z",
        "start_repeat": "2016-07-28T00:00:00.000Z",
        "end_repeat": "2016-07-31T00:00:00.000Z",
        "exception_time": null,
        "exception_type": null,
        "old_exception_type": null,
        "parent_id": null,
        "chatwork_room_id": null,
        "task_content": null,
        "message_content": null,
        "google_event_id": null,
        "google_calendar_id": null,
        "created_at": "2016-07-28T06:04:17.000Z",
        "updated_at": "2016-07-28T06:04:17.000Z",
        "deleted_at": null,
        "attendees": [
          {
            "id": 1,
            "email": "hoang.thi.nhung@framgia.com",
            "user_id": 1,
            "event_id": 154,
            "created_at": "2016-07-28T06:04:17.000Z",
            "updated_at": "2016-07-28T06:04:17.000Z"
          }
        ],
        "repeat_ons": [],
        "days_of_weeks": [],
        "event_exceptions": [],
        "notification_events": [
          {
            "id": 1,
            "event_id": 154,
            "notification_id": 1,
            "created_at": "2016-07-28T06:04:17.000Z",
            "updated_at": "2016-07-28T06:04:17.000Z"
          }
        ],
        "notifications": [
          {
            "id": 1,
            "notification_type": "Email",
            "created_at": "2016-07-15T11:05:06.000Z",
            "updated_at": "2016-07-15T11:05:06.000Z"
          }
        ],
        "calendar": {
          "id": 6,
          "user_id": 6,
          "name": "Tran Tien Thanh",
          "description": null,
          "color_id": 10,
          "status": "no_public",
          "is_default": true,
          "created_at": "2016-07-15T11:05:11.000Z",
          "updated_at": "2016-07-15T11:05:11.000Z"
        },
        "owner": {
          "id": 6,
          "name": "Tran Tien Thanh",
          "email": "tran.tien.thanh@framgia.com",
          "avatar": null,
          "chatwork_id": null,
          "google_calendar_id": "82poim9ul05t12pg4cc0u0hnvo@group.calendar.google.com",
          "token": null,
          "uid": null,
          "provider": null,
          "expires_at": null,
          "refresh_token": null,
          "email_require": false,
          "created_at": "2016-07-15T11:05:11.000Z",
          "updated_at": "2016-07-28T06:05:16.000Z",
          "auth_token": "sR47PsJhhgPGRDo673hn"
        }
      }}`

  * FAILS:

    `{"error": "Not Authenticated!"}`


### **Create Event**

**POST** [api/events.json](api/events.json)

**Params Request:**

  * `auth_token`, type: string (example: `:auth_token`)
  * `event[title]`, type: string, presence: true, length: {maximum: 255}
  * `event[start_date]`, type: datetime, presence: true
  * `event[finish_date]`, type: datetime, presence: true
  * `event[calendar_id]`, type: interger

**Request example:**

  * `POST: {
    "auth_token": "sR47PsJhhgPGRDo673hn",
    "event":
    {
      "title": "Framgia CRB",
      "start_date":"2016-07-17T00:00:00.000Z",
      "finish_date":"2016-07-17T01:00:00.000Z",
      "all_day":"1",
      "calendar_id":"6",
      "notification_events_attributes":
      {
        "0":
        {
          "notification_id":"1"
        }
      },
      "attendees_attributes":
      {
        "0":
        {
          "email":"hoang.thi.nhung@framgia.com",
          "user_id":"1"
        }
      },
      "repeat_type":"weekly",
      "repeat_every":"1",
      "start_repeat":"2016-07-17T00:00:00.000Z",
      "end_repeat":"2016-07-30T00:00:00.000Z",
      "repeat_ons_attributes":
      {
        "1":
        {
          "days_of_week_id":"2"
        },
        "2":
        {
          "days_of_week_id":"3"
        }
      },
      "repeat":"1"
      }
    }`

**Response:**

  * SUCCESS:

    `{
      "message": "Create Event Success!",
    "events": {
      "id": 174,
      "title": "Framgia CRB",
      "description": null,
      "status": null,
      "color": null,
      "all_day": true,
      "repeat_type": "weekly",
      "repeat_every": 1,
      "user_id": 6,
      "calendar_id": 6,
      "start_date": "2016-07-17T00:00:00.000Z",
      "finish_date": "2016-07-17T01:00:00.000Z",
      "start_repeat": "2016-07-17T00:00:00.000Z",
      "end_repeat": "2016-07-30T00:00:00.000Z",
      "exception_time": null,
      "exception_type": null,
      "old_exception_type": null,
      "parent_id": null,
      "chatwork_room_id": null,
      "task_content": null,
      "message_content": null,
      "google_event_id": null,
      "google_calendar_id": null,
      "created_at": "2016-07-28T09:25:35.760Z",
      "updated_at": "2016-07-28T09:25:35.760Z",
      "deleted_at": null,
      "attendees": [
        {
          "id": 7,
          "email": "hoang.thi.nhung@framgia.com",
          "user_id": 1,
          "event_id": 174,
          "created_at": "2016-07-28T09:25:35.764Z",
          "updated_at": "2016-07-28T09:25:35.764Z"
        }
      ],
      "repeat_ons": [
        {
          "id": 6,
          "event_id": 174,
          "days_of_week_id": 2,
          "created_at": "2016-07-28T09:25:35.766Z",
          "updated_at": "2016-07-28T09:25:35.766Z"
        },
        {
          "id": 7,
          "event_id": 174,
          "days_of_week_id": 3,
          "created_at": "2016-07-28T09:25:35.768Z",
          "updated_at": "2016-07-28T09:25:35.768Z"
        }
      ],
      "days_of_weeks": [
        {
          "id": 2,
          "name": "mo",
          "created_at": "2016-07-15T11:05:07.000Z",
          "updated_at": "2016-07-15T11:05:07.000Z"
        },
        {
          "id": 3,
          "name": "tu",
          "created_at": "2016-07-15T11:05:07.000Z",
          "updated_at": "2016-07-15T11:05:07.000Z"
        }
      ],
      "event_exceptions": [],
      "notification_events": [
        {
          "id": 6,
          "event_id": 174,
          "notification_id": 1,
          "created_at": "2016-07-28T09:25:35.000Z",
          "updated_at": "2016-07-28T09:25:35.000Z"
        }
      ],
      "notifications": [
        {
          "id": 1,
          "notification_type": "Email",
          "created_at": "2016-07-15T11:05:06.000Z",
          "updated_at": "2016-07-15T11:05:06.000Z"
        }
      ],
      "calendar": {
        "id": 6,
        "user_id": 6,
        "name": "Tran Tien Thanh",
        "description": null,
        "color_id": 10,
        "status": "no_public",
        "is_default": true,
        "created_at": "2016-07-15T11:05:11.000Z",
        "updated_at": "2016-07-15T11:05:11.000Z"
      },
      "owner": {
        "id": 6,
        "name": "Tran Tien Thanh",
        "email": "tran.tien.thanh@framgia.com",
        "avatar": null,
        "chatwork_id": null,
        "google_calendar_id": "82poim9ul05t12pg4cc0u0hnvo@group.calendar.google.com",
        "token": null,
        "uid": null,
        "provider": null,
        "expires_at": null,
        "refresh_token": null,
        "email_require": false,
        "created_at": "2016-07-15T11:05:11.000Z",
        "updated_at": "2016-07-28T06:05:16.000Z",
        "auth_token": "sR47PsJhhgPGRDo673hn"
      }
    }}`

  * EVENT OVERLAP:

    `{"message": "Event Overlap"}`

  * FAILS:

    `{"error": "Create Event Failed!"}`

**Note:**

  * **If Attendee don't have in database, we must add new params:**

    * `event[:attendees_attributes]`, type:string

  * **Request Example:**

    `POST: {
      "auth_token": "sR47PsJhhgPGRDo673hn",
      "event":
      {
        "title": "Framgia CRB",
        "start_date":"2016-07-17T00:00:00.000Z",
        "finish_date":"2016-07-17T01:00:00.000Z",
        "all_day":"1",
        "calendar_id":"6",
        "attendees_attributes":
        {
          "0":
            {
              "email":"tran.quang.trung@framgia.com"
            }
          }
        },
        "name":"Paris"
      }`

  * **Response:**

    `{"message": "Create Event Success!",
      "event": {
        "id": 189,
        "title": "Framgia CRB",
        "description": null,
        "status": null,
        "color": null,
        "all_day": true,
        "repeat_type": null,
        "repeat_every": null,
        "user_id": 6,
        "calendar_id": 6,
        "start_date": "2016-07-17T00:00:00.000Z",
        "finish_date": "2016-07-17T01:00:00.000Z",
        "start_repeat": null,
        "end_repeat": null,
        "exception_time": null,
        "exception_type": null,
        "old_exception_type": null,
        "parent_id": null,
        "chatwork_room_id": null,
        "task_content": null,
        "message_content": null,
        "google_event_id": null,
        "google_calendar_id": null,
        "created_at": "2016-07-28T10:51:53.906Z",
        "updated_at": "2016-07-28T10:51:53.906Z",
        "deleted_at": null,
        "attendees": [
          {
            "id": 12,
            "email": "tran.quang.trung@framgia.com",
            "user_id": 17,
            "event_id": 189,
            "created_at": "2016-07-28T10:51:53.909Z",
            "updated_at": "2016-07-28T10:51:53.909Z"
          }
        ],
        "repeat_ons": [],
        "days_of_weeks": [],
        "event_exceptions": [],
        "notification_events": [],
        "notifications": [],
        "calendar": {
          "id": 6,
          "user_id": 6,
          "name": "Tran Tien Thanh",
          "description": null,
          "color_id": 10,
          "status": "no_public",
          "is_default": true,
          "created_at": "2016-07-15T11:05:11.000Z",
          "updated_at": "2016-07-15T11:05:11.000Z"
        },
        "owner": {
          "id": 6,
          "name": "Tran Tien Thanh",
          "email": "tran.tien.thanh@framgia.com",
          "avatar": null,
          "chatwork_id": null,
          "google_calendar_id": "82poim9ul05t12pg4cc0u0hnvo@group.calendar.google.com",
          "token": null,
          "uid": null,
          "provider": null,
          "expires_at": null,
          "refresh_token": null,
          "email_require": false,
          "created_at": "2016-07-15T11:05:11.000Z",
          "updated_at": "2016-07-28T06:05:16.000Z",
          "auth_token": "sR47PsJhhgPGRDo673hn"
        },
        "place": {
          "id": 97,
          "name": "Paris",
          "address": null,
          "user_id": 6,
          "latitude": null,
          "longitude": null,
          "created_at": "2016-07-28T11:15:43.000Z",
          "updated_at": "2016-07-28T11:15:43.000Z"
        }
      }
    }}`

### **Update Event**

**PATCH** [api/events/:event_id.json](api/events/:event_id.json)

**Param request:** (3 options: delete only, delete all follow, delete all)

  * `auth_token`, type: string, presence: true (example: `:auth_token`)
  * `event[:title]`, type: string, presence: true, length: {maximum: 255}
  * `event[:start_date]`, type: datetime, presence: true
  * `event[:finish_date]`, type: datetime, presence: true
  * `event[:exception_type]`, type: string, option: edit-only/edit-all-follow/edit-all
  * `event[:end_repeat]`, type: datetime
  * `persisted`, type: interger
  * `start_time_before_change`, type:datetime

**Request example:**

  * `PATCH: {"auth_token": "LThaQcMP5s_TBo_VgjWu", "event": {"title":"CRB","start_date":"2016-07-27T00:00:00.000Z", "finish_date":"2016-07-27T23:59:00.000Z", "exception_type":"edit_only", end_repeat": null}, "persisted":"0", "start_time_before_change":null}`

**Response:**

  * SUCCESS:

    `{"message": "Event was updated successfully.", "event": {"id": 48, "title": "CRB", "description": null, "status": null, "color": null, "all_day": false, "repeat_type": null, "repeat_every": null, "user_id": 6, "calendar_id": null, "start_date": "2016-07-27T00:00:00.000Z", "finish_date": "2016-07-27T00:00:00.000Z", "start_repeat": null, "end_repeat": null, "exception_time": 2016-07-27T00:00:00.000Z", "exception_type": "edit_only", "old_exception_type": null, "parent_id": 47, "chatwork_room_id": null, "task_content": null, "message_content": null, "google_event_id": null, "google_calendar_id": null, "created_at": "2016-07-27T02:46:42.997Z", "updated_at": "2016-07-27T02:46:42.997Z", "deleted_at": null, "attendees": [], "users": [], "repeat_ons": [], "days_of_weeks": [], "event_exceptions": [], "notification_events": [], "notifications": [] "calendar": null, "owner": {"id": 4, "name": "Nguyen Quang Duy", "email": "nguyen.quang.duy@framgia.com", "avatar": null, "chatwork_id": null, "google_calendar_id": "36poim9ul05t12pg4cc0u0hnvo@group.calendar.google.com", "token": null, "uid": null, "provider": null, "expires_at": null, "refresh_token": null, "email_require": false, "created_at": "2016-07-17T11:05:11.000Z", "updated_at": "2016-07-27T02:06:59.000Z", "auth_token": "UCdwirxutvkyHUS_b_CL"}, "event_parent": null, "place": null}}`

  * Event Overlap:

    `{"message": "Event not updated because overlap"}`

**Note:**

  * **If Attendee don't have in database, we must add new params:**

    * `event[:attendees_attributes]`, type:string

  * **Request Example:**

    `PATCH: {
      "auth_token": "LThaQcMP5s_TBo_VgjWu",
      "event":
      {
        "title": "Framgia CRB",
        "start_date":"2016-07-17T00:00:00.000Z",
        "finish_date":"2016-07-17T01:00:00.000Z",
        "exception_type":"edit_only",
        "attendees_attributes":
        {
          "0":
            {
              "email":"tran.quang.trung@framgia.com"
            }
          }
        },
        "name":"Paris",
        "persisted":"0",
        "start_time_before_change":null
      }`

  * **Response:**

    `{"message": "Create Event Success!",
      "event": {
        "id": 189,
        "title": "Framgia CRB",
        "description": null,
        "status": null,
        "color": null,
        "all_day": true,
        "repeat_type": null,
        "repeat_every": null,
        "user_id": 6,
        "calendar_id": 6,
        "start_date": "2016-07-17T00:00:00.000Z",
        "finish_date": "2016-07-17T01:00:00.000Z",
        "start_repeat": null,
        "end_repeat": null,
        "exception_time": null,
        "exception_type": null,
        "old_exception_type": null,
        "parent_id": null,
        "chatwork_room_id": null,
        "task_content": null,
        "message_content": null,
        "google_event_id": null,
        "google_calendar_id": null,
        "created_at": "2016-07-28T10:51:53.906Z",
        "updated_at": "2016-07-28T10:51:53.906Z",
        "deleted_at": null,
        "attendees": [
          {
            "id": 12,
            "email": "tran.quang.trung@framgia.com",
            "user_id": 17,
            "event_id": 189,
            "created_at": "2016-07-28T10:51:53.909Z",
            "updated_at": "2016-07-28T10:51:53.909Z"
          }
        ],
        "repeat_ons": [],
        "days_of_weeks": [],
        "event_exceptions": [],
        "notification_events": [],
        "notifications": [],
        "calendar": {
          "id": 6,
          "user_id": 6,
          "name": "Tran Tien Thanh",
          "description": null,
          "color_id": 10,
          "status": "no_public",
          "is_default": true,
          "created_at": "2016-07-15T11:05:11.000Z",
          "updated_at": "2016-07-15T11:05:11.000Z"
        },
        "owner": {
          "id": 6,
          "name": "Tran Tien Thanh",
          "email": "tran.tien.thanh@framgia.com",
          "avatar": null,
          "chatwork_id": null,
          "google_calendar_id": "82poim9ul05t12pg4cc0u0hnvo@group.calendar.google.com",
          "token": null,
          "uid": null,
          "provider": null,
          "expires_at": null,
          "refresh_token": null,
          "email_require": false,
          "created_at": "2016-07-15T11:05:11.000Z",
          "updated_at": "2016-07-28T06:05:16.000Z",
          "auth_token": "sR47PsJhhgPGRDo673hn"
        }
      }
    }}`


### **Delete Event**

**DELETE** [api/events/:event_id.json](api/events/:event_id.json)

**Param request:** (3 options: delete only, delete all follow, delete all)

  * `auth_token`, type: string, presence: true (example: `:auth_token`)
  * `exception_type`, type: string, options: delete-only/delete-all-follow/delete-all
  * `exception_time`, type: datetime
  * `start_date_before_delete`, type:datetime

**Request example:**

  * `DELETE: {"auth_token": "LThaQcMP5s_TBo_VgjWu", "exception_type": "delete_only", "exception_time": "2016-07-28T00:00:00.000Z", "start_date_before_delete": "2016-07-28T00:00:00.000Z"}`

**Response**

  * SUCCESS:

    `{"message": "Event deleted"}`

  * FAILS:

    `{}`

# **3. Search Api**
-------------------

### **Search Attendee**

**GET** [api/search](api/search)

**Param request:**

  * `auth_token`, type: string, presence: true (example: `:auth_token`)
  * `term`, type: string

**Request example:**

  * `GET: {"term": "t"}`

**Response:**

  `[{"email":"chu.anh.tuan@framgia.com","user_id":3},{"email":"hoang.thi.nhung@framgia.com","user_id":1},{"email":"le.thi.thuy@framgia.com","user_id":10},{"email":"nguyen.thi.phuong@framgia.com","user_id":5},{"email":"nguyen.van.thieub@framgia.com","user_id":13},{"email":"tran.tien.thanh@framgia.com","user_id":6}]`

### ** SEARCH USER**

**GET** [api/search](api/search)

**Params Request:**

  * `auth_token`, type: string, presence: true (example: `:auth_token`)
  * `term`, type: string
