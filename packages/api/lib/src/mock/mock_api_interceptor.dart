import 'package:dio/dio.dart';

class MockApiInterceptor extends Interceptor {
  final Map<String, dynamic> mockResponses = {
    'POST:/projects/create-project': {
      "project": {
        "id": "c120e8203",
        "userId": "admin",
        "name": "New Project",
        "templateId": "basic",
        "createdAt": "2024-10-22T09:00:00Z",
        "modifiedAt": "2024-10-22T10:30:00Z",
        "pages": [
          {
            "id": "p11j2k222",
            "title": "페이지 타이틀 cover",
            "idref": "cover",
            "linear": true,
            "properties": {},
            "href": "cover.xhtml",
            "thumbnail": "page001.png",
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z"
          },
          {
            "id": "pa233k442",
            "title": "페이지 목차 nav",
            "idref": "nav",
            "linear": true,
            "properties": {},
            "href": "toc.xhtml",
            'thumbnail': 'page002.png',
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z",
          },
          {
            "id": "p0k220213",
            "title": "페이지 목차 페이지1",
            "idref": "page1",
            "linear": true,
            "properties": {"page-spread-left": true},
            "href": "page1.xhtml",
            'thumbnail': 'page003.png',
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z",
          },
        ],
      },
      "folder": {
        "id": "fs50e24s1",
        "name": "root",
        "type": "root",
        "createdAt": "2024-10-12T09:00:00Z",
        "modifiedAt": "2024-10-14T15:30:00Z",
        "contentLength": '1',
        "contents": [
          {
            "id": "f123d123",
            "name": "EX folder",
            "type": "folder",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '2',
          },
          {
            "id": "c120e8203",
            "name": "New Project",
            "type": "project",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '0',
          },
          {
            "id": "c120e8203",
            "name": "New Project22",
            "type": "project",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '0',
          },
        ]
      },
    },
    'GET:/projects': {
      "projects": [
        {
          "id": "c120e8203",
          "userId": "admin",
          "name": "Updated Project Name",
          "templateId": "basic",
          "createdAt": "2024-10-22T09:00:00Z",
          "modifiedAt": "2024-10-22T10:30:00Z",
          "pages": [
            {
              "id": "p11j2k222",
              "title": "페이지 타이틀 cover",
              "idref": "cover",
              "linear": true,
              "href": "cover.xhtml",
              "thumbnail": "page001.png",
              "createdAt": "2024-10-22T09:00:00Z",
              "modifiedAt": "2024-10-22T10:30:00Z"
            },
            {
              "id": "pa233k442",
              "title": "페이지 목차 nav",
              "idref": "nav",
              "linear": true,
              "properties": {},
              "href": "toc.xhtml",
              'thumbnail': 'page002.png',
              "createdAt": "2024-10-22T09:00:00Z",
              "modifiedAt": "2024-10-22T10:30:00Z",
            },
            {
              "id": "p0k220213",
              "title": "페이지 목차 페이지1",
              "idref": "page1",
              "linear": true,
              "properties": {"page-spread-left": true},
              "href": "page1.xhtml",
              'thumbnail': 'page003.png',
              "createdAt": "2024-10-22T09:00:00Z",
              "modifiedAt": "2024-10-22T10:30:00Z",
            },
          ],
        },
      ]
    },
    'GET:/projects/recent': {
      "projects": [
        {
          'id': 'c120e8203',
          'userId': 'admin',
          'name': 'Latest Project',
          'templateId': 'basic',
          'createdAt': '2024-10-22T09:00:00Z',
          'modifiedAt': '2024-10-22T15:30:00Z',
          'pages': []
        },
        {
          'id': 'cb4fe8201',
          'userId': 'admin',
          'name': 'Second Recent Project',
          'templateId': 'basic',
          'createdAt': '2024-10-21T10:00:00Z',
          'modifiedAt': '2024-10-22T14:20:00Z',
          'pages': []
        },
        {
          'id': 'c590e8202',
          'userId': 'admin',
          'name': 'Third Recent Project',
          'templateId': 'basic',
          'createdAt': '2024-10-20T11:00:00Z',
          'modifiedAt': '2024-10-22T13:10:00Z',
          'pages': []
        }
      ]
    },
    'GET:/projects/c120e8203': {
      "project": {
        "id": "c120e8203",
        "userId": "admin",
        "name": "Updated Project Name",
        "templateId": "basic",
        "createdAt": "2024-10-22T09:00:00Z",
        "modifiedAt": "2024-10-22T10:30:00Z",
        "pages": [
          {
            "id": "p11j2k222",
            "title": "페이지 타이틀 cover",
            "idref": "cover",
            "linear": true,
            "href": "cover.xhtml",
            "thumbnail": "page001.png",
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z"
          },
          {
            "id": "pa233k442",
            "title": "페이지 목차 nav",
            "idref": "nav",
            "linear": true,
            "properties": {},
            "href": "toc.xhtml",
            'thumbnail': 'page002.png',
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z",
          },
          {
            "id": "p0k220213",
            "title": "페이지 목차 페이지1",
            "idref": "page1",
            "linear": true,
            "properties": {"page-spread-left": true},
            "href": "page1.xhtml",
            'thumbnail': 'page003.png',
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z",
          },
        ],
      }
    },
    'DELETE:/projects/c120e8203': {
      "folder": {
        "id": "fs50e24s1",
        "name": "root",
        "type": "root",
        "createdAt": "2024-10-12T09:00:00Z",
        "modifiedAt": "2024-10-14T15:30:00Z",
        "contentLength": '0',
        "contents": []
      }
    },
    'DELETE:/projects/c120e8203/resources/c120e8203': {
      'statusCode': 200,
      "message": "Project resources deleted successfully"
    },
    'POST:/projects/move': {
      "folder": {
        "id": "fs50e24s1",
        "name": "root",
        "type": "root",
        "createdAt": "2024-10-12T09:00:00Z",
        "modifiedAt": "2024-10-14T15:30:00Z",
        "contentLength": '1',
        "contents": [
          {
            "id": "f123d123",
            "name": "EX folder",
            "type": "folder",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '3',
          },
          {
            "id": "f456d123",
            "name": "taget folder",
            "type": "folder",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '1',
          },
        ]
      }
    },
    'PATCH:/projects': {
      "project": {
        "id": "c120e8203",
        "userId": "string",
        "name": "string",
        "templateId": "string",
        "createdAt": "2024-11-07T05:58:07.576Z",
        "modifiedAt": "2024-11-07T05:58:07.576Z",
        "pages": [
          {
            "idref": "string",
            "linear": true,
            "href": "string",
            "thumbnail": "string",
            "properties": {},
            "createdAt": "2024-11-07T05:58:07.576Z",
            "modifiedAt": "2024-11-07T05:58:07.576Z"
          }
        ]
      },
      "folder": {
        "id": "fs50e24s0",
        "name": "Updated Project",
        "type": "folder",
        "createdAt": "2024-11-07T05:58:07.576Z",
        "modifiedAt": "2024-11-07T05:58:07.576Z",
        "contentLength": "1",
        "contents": [
          {
            "id": "fs50e24s0",
            "name": "Updated Project",
            "type": "folder",
            "createdAt": "2024-11-07T05:58:07.576Z",
            "modifiedAt": "2024-11-07T05:58:07.576Z",
            "contentLength": "15"
          }
        ]
      }
    },
    'POST:/create-folder': {
      "folder": {
        "id": "fs50e24s1",
        "name": "root",
        "type": "root",
        "createdAt": "2024-10-12T09:00:00Z",
        "modifiedAt": "2024-10-14T15:30:00Z",
        "contentLength": '2',
        "contents": [
          {
            "id": "c120e8203",
            "name": "New Project",
            "type": "project",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '0',
          },
          {
            "id": "fs50e24s0",
            "name": "Folder A",
            "type": "folder",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '0',
          },
        ]
      }
    },
    'GET:/folders/root': {
      "folder": {
        "id": "root",
        "name": "root",
        "type": "root",
        "createdAt": "2024-10-12T09:00:00Z",
        "modifiedAt": "2024-10-14T15:30:00Z",
        "contentLength": '1',
        "contents": [
          {
            "id": "f123d123",
            "name": "EX folder",
            "type": "folder",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '2',
          },
          {
            "id": "f456d123",
            "name": "taget folder",
            "type": "folder",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '1',
          },
          {
            "id": "c120e8203",
            "name": "New Project",
            "type": "project",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '0',
          },
        ]
      }
    },
    'GET:/folders/fs50e24s0': {
      "folder": {
        "id": "fs50e24s0",
        "name": "Folder A",
        "type": "folder",
        "createdAt": "2024-10-12T09:00:00Z",
        "modifiedAt": "2024-10-14T15:30:00Z",
        "contentLength": 0,
        "contents": []
      }
    },
    'GET:/folders/f123d123': {
      "folder": {
        "id": "f123d123",
        "name": "EX folder",
        "type": "folder",
        "createdAt": "2024-10-13T11:20:00Z",
        "modifiedAt": "2024-10-15T09:15:00Z",
        "contentLength": '2',
        "contents": [
          {
            "id": "c120e8203",
            "name": "New Project",
            "type": "project",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '0',
          },
        ]
      }
    },
    'DELETE:/folders/c120e8203': {
      "folder": {
        "id": "fs50e24s1",
        "name": "root",
        "type": "root",
        "createdAt": "2024-10-12T09:00:00Z",
        "modifiedAt": "2024-10-14T15:30:00Z",
        "contentLength": '1',
        "contents": []
      }
    },
    'PATCH:/folders': {
      "folder": {
        "id": "fs50e24s1",
        "name": "root",
        "type": "root",
        "createdAt": "2024-10-12T09:00:00Z",
        "modifiedAt": "2024-10-14T15:30:00Z",
        "contentLength": '1',
        "contents": [
          {
            "id": "fs50e24s0",
            "name": "Updated Folder Name",
            "type": "folder",
            "createdAt": "2024-10-12T09:00:00Z",
            "modifiedAt": "2024-10-14T15:30:00Z",
            "contentLength": '0',
          }
        ]
      }
    },
    'GET:/pages': {
      "pages": [
        {
          "idref": "cover",
          "linear": true,
          "href": "cover.xhtml",
          "thumbnail": "page001.png",
          "createdAt": "2024-10-22T09:00:00Z",
          "modifiedAt": "2024-10-22T10:30:00Z"
        },
        {
          "idref": "nav",
          "linear": true,
          "href": "toc.xhtml",
          "thumbnail": "page002.png",
          "properties": {},
          "createdAt": "2024-10-22T09:00:00Z",
          "modifiedAt": "2024-10-22T10:30:00Z"
        }
      ]
    },
    'POST:/pages/create-page': {
      "page": {
        "id": "p02322s13",
        "title": "페이지 목차 페이지2",
        "idref": "page2",
        "linear": true,
        "properties": {"page-spread-left": true},
        "href": "page2.xhtml",
        'thumbnail': 'page003.png',
        "createdAt": "2024-10-22T09:00:00Z",
        "modifiedAt": "2024-10-22T10:30:00Z",
      },
      "project": {
        "id": "c120e8203",
        "userId": "admin",
        "name": "Test Project",
        "templateId": "basic",
        "createdAt": "2024-10-22T09:00:00Z",
        "modifiedAt": "2024-10-22T10:30:00Z",
        "pages": [
          {
            "id": "p11j2k222",
            "title": "페이지 타이틀 cover",
            "idref": "cover",
            "linear": true,
            "href": "cover.xhtml",
            "thumbnail": "page001.png",
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z"
          },
          {
            "id": "pa233k442",
            "title": "페이지 목차 nav",
            "idref": "nav",
            "linear": true,
            "properties": {},
            "href": "toc.xhtml",
            'thumbnail': 'page002.png',
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z",
          },
          {
            "id": "p0k220213",
            "title": "페이지 목차 페이지1",
            "idref": "page1",
            "linear": true,
            "properties": {"page-spread-left": true},
            "href": "page1.xhtml",
            'thumbnail': 'page003.png',
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z",
          },
          {
            "id": "p02322s13",
            "title": "페이지 목차 페이지2",
            "idref": "page2",
            "linear": true,
            "properties": {"page-spread-left": true},
            "href": "page2.xhtml",
            'thumbnail': 'page003.png',
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z",
          }
        ]
      }
    },
    'DELETE:/pages': {
      "project": {
        "id": "c120e8203",
        "userId": "admin",
        "name": "Test Project",
        "templateId": "basic",
        "createdAt": "2024-10-22T09:00:00Z",
        "modifiedAt": "2024-10-22T10:30:00Z",
        "pages": [
          {
            "id": "p11j2k222",
            "title": "페이지 타이틀 cover",
            "idref": "cover",
            "linear": true,
            "href": "cover.xhtml",
            "thumbnail": "page001.png",
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z"
          },
          {
            "id": "pa233k442",
            "title": "페이지 목차 nav",
            "idref": "nav",
            "linear": true,
            "properties": {},
            "href": "toc.xhtml",
            'thumbnail': 'page002.png',
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z",
          },
          {
            "id": "p0k220213",
            "title": "페이지 목차 페이지1",
            "idref": "page1",
            "linear": true,
            "properties": {"page-spread-left": true},
            "href": "page1.xhtml",
            'thumbnail': 'page003.png',
            "createdAt": "2024-10-22T09:00:00Z",
            "modifiedAt": "2024-10-22T10:30:00Z",
          },
        ]
      }
    },
    'POST:/folders/move': {
      "folder": {
        "id": "f123d123",
        "name": "moveFolder",
        "type": "folder",
        "createdAt": "2024-11-06T06:03:20.901Z",
        "modifiedAt": "2024-11-06T06:03:20.901Z",
        "contentLength": "2",
        "contents": [
          {
            "id": "f456d123",
            "name": "taget folder",
            "type": "folder",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '1',
          },
          {
            "id": "c120e8203",
            "name": "New Project",
            "type": "project",
            "createdAt": "2024-10-13T11:20:00Z",
            "modifiedAt": "2024-10-15T09:15:00Z",
            "contentLength": '0',
          },
        ]
      }
    },
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String key = '${options.method}:${options.path}';

    // Handle query parameters for pages endpoints
    if (options.path.startsWith('/pages')) {
      // Remove query parameters from the path for matching
      if (options.path.contains('?')) {
        key = '${options.method}:${options.path.split('?')[0]}';
      }
    }

    if (mockResponses.containsKey(key)) {
      handler.resolve(Response(
        requestOptions: options,
        data: mockResponses[key],
        statusCode: 200,
      ));
    } else {
      handler.next(options);
    }
  }
}
