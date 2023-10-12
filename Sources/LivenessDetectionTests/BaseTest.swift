//
//  BaseTest.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 17/02/2023.
//

import XCTest
import UIKit
import Vision
@testable import LivenessDetection

let indexURL = URL(string: "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/index.json")!

class BaseTest<T: SpoofDetector>: XCTestCase {
    let live = [
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-01T20-29-14.131Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-13T13-34-23.450Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T09-46-57.964Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T09-55-29.921Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T10-57-40.653Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T11-05-53.110Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T20-57-56.798Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T20-58-44.778Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T20-59-02.381Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-04-33.179Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-07-10.656Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-07-35.971Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-14-34.617Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-15-26.848Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-29-28.729Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-29-28.729Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-29-40.494Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-29-40.494Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-39-29.553Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-39-29.553Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-39-40.345Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-39-40.345Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-42-04.984Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-15T14-28-20.851Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-19T08-00-20.215Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-19T08-00-29.286Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-19T15-42-47.277Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-19T15-42-58.411Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-20T16-03-23.367Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-20T16-43-44.309Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-20T16-45-30.455Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-34-30.885Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-34-54.572Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-35-02.925Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-35-16.475Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-35-53.080Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-36-31.026Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-08.692Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-17.289Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-28.766Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-28.766Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-43.000Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-43.000Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-55.415Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-55.415Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-44-39.236Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-44-51.144Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-45-29.640Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-46-36.742Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-46-36.742Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-51-10.917Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-51-25.718Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-51-40.860Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-51-40.860Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-52-23.149Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-52-23.149Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-55-32.877Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-55-43.754Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-55-56.455Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-56-30.948Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-56-50.931Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-56-50.931Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T09-51-36.194Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T09-59-48.082Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-00-02.568Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-00-25.281Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-00-42.186Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-00-59.073Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-01-19.637Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-01-38.682Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-02-24.051Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-02-39.326Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T13-59-05.961Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-05-01.416Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-05-34.824Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-07-13.116Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-07-56.827Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-15-45.803Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-16-20.316Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-31-03.393Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-31-03.393Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T17-01-54.315Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T17-02-09.474Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-17-46.312Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-17-46.312Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-20-14.897Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-20-47.985Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-20-47.985Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-21-00.952Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-21-13.844Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-22-05.380Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-22-05.380Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-22-57.106Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-34-08.197Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-34-40.135Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-34-40.135Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T12-49-54.991Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T15-51-57.366Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T15-51-57.366Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T15-52-32.143Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T15-52-55.461Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T15-53-26.796Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-06T15-53-53.855Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T05-43-27.397Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T05-44-38.230Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T05-52-18.375Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T05-52-30.914Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T05-52-52.276Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T05-56-38.488Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T05-56-56.407Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T05-57-23.971Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T07-33-52.295Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T07-34-16.048Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T09-37-33.459Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T09-38-59.004Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T09-53-18.610Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T09-53-50.976Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T10-34-11.088Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T10-35-23.815Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T10-42-51.649Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T10-43-21.089Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T10-43-49.175Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T10-46-33.608Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T10-54-16.230Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T10-55-09.273Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-04-50.866Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-12-01.190Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-12-36.286Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-13-04.684Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-17-03.405Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-21-32.545Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-21-55.184Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-31-28.328Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-37-23.931Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-45-21.557Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-46-46.868Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-47-02.421Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T11-52-29.876Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-08-59.118Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-10-28.793Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-10-42.740Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-13-32.974Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-25-04.671Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-36-52.459Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-44-32.924Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-44-56.582Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-45-08.486Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-56-55.160Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-57-31.640Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-09T12-57-44.526Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T05-48-06.455Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T05-51-10.386Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T05-51-59.633Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T05-58-10.135Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T05-58-41.509Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T05-59-07.013Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T05-59-35.749Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T05-59-54.352Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T06-03-43.922Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T06-05-33.902Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T06-10-01.829Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T06-17-53.305Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T06-18-17.305Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T06-27-10.105Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T06-43-03.583Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T06-43-33.169Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T08-31-52.109Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T08-32-14.964Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T08-32-40.370Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-03-45.552Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-05-49.248Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-15-39.301Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-30-03.099Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-38-25.850Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-38-37.505Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-38-49.468Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-39-06.064Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-39-17.510Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-39-30.989Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-39-43.472Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-39-55.228Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-44-51.819Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-45-06.922Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-45-28.700Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-45-45.029Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T14-45-59.672Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T15-03-31.121Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T15-03-43.034Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T15-03-55.790Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T15-23-12.065Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T15-25-00.538Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T15-26-25.835Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T19-12-32.929Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T19-12-59.428Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T19-18-59.426Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T21-12-46.243Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T21-13-18.093Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T21-13-39.711Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T21-14-04.681Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T21-14-21.922Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-10T21-21-04.655Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-16-16.023Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-16-34.811Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-38-17.234Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-38-30.485Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-38-56.960Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-39-22.081Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-39-47.710Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-40-22.261Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-40-48.884Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-41-01.887Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-41-26.614Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-41-47.808Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-42-09.750Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-42-37.086Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-43-04.583Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-43-18.048Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-43-48.565Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-44-03.968Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-44-35.301Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-44-49.752Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-45-14.498Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-45-31.069Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-46-56.157Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T06-47-08.384Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T09-10-10.361Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T09-10-40.129Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T09-20-18.956Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T09-20-35.443Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T12-33-32.311Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T12-49-45.603Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-11T12-49-58.661Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T07-29-46.993Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T07-34-32.217Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T07-34-54.503Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T07-35-10.966Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T07-35-27.197Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T07-50-05.899Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T11-08-38.375Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T12-21-14.494Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T12-33-38.446Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T12-47-40.141Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-00-32.860Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-01-59.623Z.zip-1.jpg"
    ]
    let spoof = [
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T09-56-30.522Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T09-56-48.121Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T09-56-57.524Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T21-28-48.956Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T21-28-48.956Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T21-29-17.737Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T21-29-17.737Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-18T19-39-22.309Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-18T19-39-44.146Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-18T19-48-48.012Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-12-03.335Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-17-02.753Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-17-26.568Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-17-54.816Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-18-22.918Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-19-04.998Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-19-31.318Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-19-55.663Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-19-55.663Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-29-57.963Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-30-09.090Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-30-36.658Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T12-21-31.053Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T12-21-49.689Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T12-22-20.002Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T12-51-04.850Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T12-53-10.574Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T12-59-24.056Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T12-59-42.689Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T14-01-36.526Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T15-46-59.958Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T15-47-15.206Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T15-47-33.127Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T15-51-09.692Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-06T15-51-27.518Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-09T05-58-16.263Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-09T05-58-46.241Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-09T05-59-04.558Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-09T08-32-31.077Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-09T10-22-10.233Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-09T10-22-23.316Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-09-26.341Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-09-47.405Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-10-38.108Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-10-52.499Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-11-12.799Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-11-34.691Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-15-51.883Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-16-14.635Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-16-33.395Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-16-52.601Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-17-25.774Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-17-45.549Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-17-57.036Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-18-11.100Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-18-31.390Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-18-50.589Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-29-20.182Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-29-39.602Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-30-24.004Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-31-28.063Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-31-40.081Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-31-54.819Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-32-12.771Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-32-27.741Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-32-57.429Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-33-07.715Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-33-29.624Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-33-47.375Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-40-12.984Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-40-27.724Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-46-32.013Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-46-47.485Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-47-08.763Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-47-20.662Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-47-47.962Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-47-57.936Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-48-24.593Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-49-15.027Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-49-27.305Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-49-48.514Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T14-49-59.315Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T15-24-05.525Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T15-24-21.558Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T15-25-24.063Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T15-25-40.106Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T15-26-08.049Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T15-26-42.770Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-13-39.111Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-13-49.102Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-14-00.290Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-14-45.689Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-14-57.215Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-15-23.927Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-16-33.068Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-16-47.232Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-18-04.265Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-18-13.692Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-18-32.329Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-19-14.680Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T19-19-26.795Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-14-55.098Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-15-15.402Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-15-42.434Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-15-52.844Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-16-07.404Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-16-35.270Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-16-51.642Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-17-01.138Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-17-10.102Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-17-20.097Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-17-53.758Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-18-14.233Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-18-24.690Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-18-39.021Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-19-04.534Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-19-29.723Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-19-43.707Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-19-59.426Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-20-14.175Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-22-04.011Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-22-22.757Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-22-45.880Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-22-56.040Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-10T21-23-07.187Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T09-12-02.746Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T09-12-16.303Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T09-12-31.716Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T09-12-45.199Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T09-13-01.377Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T09-13-17.833Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T09-13-32.218Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T09-15-56.136Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T09-16-09.331Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T12-34-00.164Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-11T12-34-51.877Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T07-36-12.175Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T07-36-27.462Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T07-36-40.336Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T07-36-54.038Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T07-39-07.596Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T07-39-20.977Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T07-47-24.344Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T07-47-46.431Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T11-09-08.384Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T11-09-21.318Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T11-09-48.479Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T11-10-03.203Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T11-10-23.740Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T11-10-38.241Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T11-10-51.329Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T11-11-04.798Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T11-11-19.409Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-21-41.582Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-21-53.129Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-22-36.288Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-22-48.634Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-23-06.841Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-33-51.650Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-34-01.746Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-34-20.065Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-34-33.745Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-34-45.595Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-35-17.432Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-35-28.380Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-35-40.768Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-36-08.276Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-36-20.649Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-36-42.737Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-47-17.335Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-48-05.208Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-48-18.941Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-48-32.298Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-48-46.621Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-49-08.699Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-49-44.000Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T12-49-56.122Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-00-47.148Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-00-59.682Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-01-13.819Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-01-26.560Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-02-14.360Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-02-29.252Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-02-46.737Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-03-20.993Z.zip-1.jpg"
    ]

    
    private var moireDetectorModelURL: URL!
    private var spoofDeviceDetectorModelURL: URL!
    private var spoofDetectorModelURL: URL!
    private var spoofDetector4ModelURLs: [URL] = []
    private var spoofDetector5ModelURL: URL!
    private var imageURLs: [LivenessDetectionType:[Bool:[URL]]] = [:]
    var spoofDetector: T!
    var expectedSuccessRate: Float {
        0.9
    }
    var confidenceThreshold: Float {
        0.45
    }
    let expectedFPRate: Float = 0.1
    let expectedFNRate: Float = 0.1
    
    override class func setUp() {
        super.setUp()
        do {
            let cacheURL = try cacheURL(of: indexURL)
            try FileManager.default.removeItem(at: cacheURL)
        } catch {
        }
    }

    override func setUpWithError() throws {
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/MoireDetectorModel_ep100_ntrn-627p-620n_02_res-98-99-96-0-5.mlmodel") {
            self.moireDetectorModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/ARC_PSD-001_1.1.29_bst_yl80_NMS_ult145_cml620.mlmodel") {
            self.spoofDeviceDetectorModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/ARC_PSD-003_1.0.16_TRCD.mlmodel") {
            self.spoofDetectorModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        self.spoofDetector4ModelURLs = []
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/ARC_PSD-004_2.7_80x80.mlmodel") {
            self.spoofDetector4ModelURLs.append(try self.localURL(of: url))
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/ARC_PSD-004_4_80x80.mlmodel") {
            self.spoofDetector4ModelURLs.append(try self.localURL(of: url))
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://ver-id.s3.amazonaws.com/ml-models/mobilenetv2-epoch_10.tflite") {
            self.spoofDetector5ModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        self.imageURLs.removeAll()
        self.imageURLs[LivenessDetectionType.moire] = [
            false: self.live.compactMap { URL(string: $0) },
            true: self.spoof.compactMap { URL(string: $0) }
        ]
        self.imageURLs[LivenessDetectionType.spoofDevice] = [
            false: self.live.compactMap { URL(string: $0) },
            true: self.spoof.compactMap { URL(string: $0) }
        ]
//        let indexData = try Data(contentsOf: self.localURL(of: indexURL))
//        let index: [String:[String:[String]]] = try JSONDecoder().decode([String:[String:[String]]].self, from: indexData)
//        try index.forEach({ key, val in
//            guard let type = LivenessDetectionType(rawValue: key) else {
//                throw NSError()
//            }
//            self.imageURLs[type] = [:]
//            for k in val.keys {
//                let positive = k == "positive"
//                self.imageURLs[type]?[positive] = []
//                for urlString in val[k]! {
//                    guard let url = URL(string: urlString) else {
//                        throw NSError()
//                    }
//                    self.imageURLs[type]?[positive]?.append(url)
//                }
//            }
//        })
        self.spoofDetector = try self.createSpoofDetector()
        self.spoofDetector.confidenceThreshold = self.confidenceThreshold
    }
    
    func createSpoofDetector() throws -> T {
        fatalError("Method not implemented")
    }
    
    func test_detectSpoofInImages_succeedsWithExpectedSuccessRate() throws {
        var liveCount = 0
        var spoofCount = 0
        var fpCount = 0
        var fnCount = 0
        try self.withEachImage(types: [.moire,.spoofDevice]) { image, url, positive in
            let roi = try self.detectFaceInImage(image)?.boundingBox
            let isSpoof = try self.spoofDetector.isSpoofedImage(image, regionOfInterest: roi)
            if positive && !isSpoof {
                fnCount += 1
            } else if !positive && isSpoof {
                fpCount += 1
            }
            if positive {
                spoofCount += 1
            } else {
                liveCount += 1
            }
        }
        let fpRate = Float(fpCount) / Float(liveCount)
        let fnRate = Float(fnCount) / Float(spoofCount)
        XCTAssertLessThanOrEqual(fpRate, self.expectedFPRate)
        XCTAssertLessThanOrEqual(fnRate, self.expectedFNRate)
    }
    
    func test_measureInferenceSpeed() throws {
        let image = try self.firstImage(type: .spoofDevice, positive: true)
        let measureOptions = XCTMeasureOptions.default
        measureOptions.invocationOptions = [.manuallyStart, .manuallyStop]
        self.measure(options: measureOptions) {
            do {
                let roi = try self.detectFaceInImage(image)?.boundingBox
                self.startMeasuring()
                _ = try self.spoofDetector.detectSpoofInImage(image, regionOfInterest: roi)
                self.stopMeasuring()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    static func cacheURL(of url: URL) throws -> URL {
        let cacheURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return cacheURL.appendingPathComponent(url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
    }
    
    func localURL(of url: URL) throws -> URL {
        let localURL = try BaseTest.cacheURL(of: url)
        if !FileManager.default.fileExists(atPath: localURL.path) {
            try FileManager.default.createDirectory(at: localURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try Data(contentsOf: url)
            try data.write(to: localURL, options: .atomic)
        }
        return localURL
    }
    
    func image(at url: URL) throws -> UIImage {
        let localURL = try self.localURL(of: url)
        let data = try Data(contentsOf: localURL)
        guard let image = UIImage(data: data) else {
            throw NSError()
        }
        return image
    }
    
    func cgImage(at url: URL) throws -> CGImage {
        let uiImage = try self.image(at: url)
        return try self.cgImage(from: uiImage)
    }
    
    func cgImage(from uiImage: UIImage) throws -> CGImage {
        if let image = uiImage.cgImage {
            return image
        } else if let ciImage = uiImage.ciImage {
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                return cgImage
            }
        }
        throw NSError()
    }
    
    func imageURLs(types: [LivenessDetectionType]) throws -> [(URL,Bool)] {
        var urls: Set<FlaggedURL> = []
        for t in types {
            guard let map = self.imageURLs[t] else {
                throw NSError()
            }
            for positive in map.keys {
                map[positive]!.map({ FlaggedURL(url: $0, flagged: positive) }).forEach({
                    urls.insert($0)
                })
            }
        }
        return urls.map({ ($0.url, $0.flagged) })
    }
    
    func withEachImage(types: [LivenessDetectionType], run: (UIImage,URL,Bool) throws -> Void) throws {
        let urls = try self.imageURLs(types: types)
        for url in urls {
            let image = try self.image(at: url.0)
            try run(image, url.0, url.1)
        }
    }
    
    func withEachCGImage(types: [LivenessDetectionType], run: (CGImage,URL,Bool) throws -> Void) throws {
        let urls = try self.imageURLs(types: types)
        for url in urls {
            let image = try self.cgImage(at: url.0)
            try run(image, url.0, url.1)
        }
    }
    
    func firstImage(type: LivenessDetectionType, positive: Bool) throws -> UIImage {
        guard let url = try self.imageURLs(types: [type]).first(where: { $0.1 == positive })?.0 else {
            throw NSError()
        }
        return try self.image(at: url)
    }
    
    func firstCGImage(type: LivenessDetectionType, positive: Bool) throws -> CGImage {
        guard let url = try self.imageURLs(types: [type]).first(where: { $0.1 == positive })?.0 else {
            throw NSError()
        }
        return try self.cgImage(at: url)
    }

    func createMoireDetector() throws -> MoireDetector {
        return try MoireDetector(modelURL: self.moireDetectorModelURL)
    }
    
    @available(iOS 14, *)
    func createSpoofDeviceDetector() throws -> SpoofDeviceDetector {
        return try SpoofDeviceDetector(modelURL: self.spoofDeviceDetectorModelURL)
    }
    
    func createSpoofDetector3() throws -> SpoofDetector3 {
        return try SpoofDetector3(modelURL: self.spoofDetectorModelURL)
    }
    
    func createSpoofDetector4() throws -> SpoofDetector4 {
        return try SpoofDetector4(modelURL1: self.spoofDetector4ModelURLs[0], modelURL2: self.spoofDetector4ModelURLs[1])
    }
    
    func image(_ image: UIImage, croppedToEyeRegionsOfFace face: VNFaceObservation) -> UIImage {
        guard let rightEye = face.landmarks?.leftPupil?.pointsInImage(imageSize: image.size).first else {
            return image
        }
        guard let leftEye = face.landmarks?.rightPupil?.pointsInImage(imageSize: image.size).first else {
            return image
        }
        let distanceBetweenEyes = hypot(rightEye.y - leftEye.y, rightEye.x - leftEye.x)
        let cropRect = CGRect(x: leftEye.x - distanceBetweenEyes * 0.75, y: min(leftEye.y, rightEye.y) - distanceBetweenEyes * 0.5, width: distanceBetweenEyes * 2.5, height: distanceBetweenEyes)
        UIGraphicsBeginImageContext(cropRect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(at: CGPoint(x: 0-cropRect.minX, y: 0-cropRect.minY))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func image(_ image: UIImage, croppedToFace face: VNFaceObservation) -> UIImage {
        UIGraphicsBeginImageContext(face.boundingBox.size)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(at: CGPoint(x: 0-face.boundingBox.minX, y: 0-face.boundingBox.minY))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func failRatioOfDetectionOnEachImage(_ detector: SpoofDetector, detectFace: Bool) throws -> Float {
        var detectionCount: Float = 0
        var failCount: Float = 0
        try withEachImage(types: [.spoofDevice]) { (image, url, positive) in
            let roi = try self.detectFaceInImage(image)?.boundingBox
            let isSpoof = try detector.isSpoofedImage(image, regionOfInterest: roi)
            let success = (positive && isSpoof) || (!positive && !isSpoof)
            detectionCount += 1
            if !success {
                failCount += 1
            }
        }
        return failCount / detectionCount
    }
    
    func falsePositiveAndNegativeRatiosOnEachImage(detectors: [SpoofDetector], detectFace: Bool) throws -> (Float, Float) {
        var fpCount: Float = 0
        var fnCount: Float = 0
        var totalCount: Float = 0
        try withEachImage(types: [.moire,.spoofDevice]) { (image, url, positive) in
            totalCount += 1
            let roi = try self.detectFaceInImage(image)?.boundingBox
            var isSpoof: Bool = false
            for detector in detectors {
                if try detector.isSpoofedImage(image, regionOfInterest: roi) {
                    isSpoof = true
                    break
                }
            }
            if positive && !isSpoof {
                fnCount += 1
            } else if !positive && isSpoof {
                fpCount += 1
            }
        }
        return (fpCount / totalCount, fnCount / totalCount)
    }
    
    func detectFaceInImage(_ image: UIImage) throws -> VNFaceObservation? {
        let cgImage = try self.cgImage(from: image)
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.imageOrientation.cgImagePropertyOrientation, options: [:])
        let request = VNDetectFaceRectanglesRequest()
        request.usesCPUOnly = true
        try imageRequestHandler.perform([request])
        return request.results?.first
    }
    
    func detectFacesInImage(_ image: UIImage) throws -> [CGRect] {
        let cgImage = try self.cgImage(from: image)
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.imageOrientation.cgImagePropertyOrientation, options: [:])
        let request = VNDetectFaceRectanglesRequest()
        request.usesCPUOnly = true
        try imageRequestHandler.perform([request])
        return request.results?.map { obs in
            obs.boundingBox
        } ?? []
    }
}

enum LivenessDetectionType: String, Decodable {
    case moire = "moire", spoofDevice = "spoof_device"
}

fileprivate struct FlaggedURL: Hashable {
    
    let url: URL
    let flagged: Bool
}

extension UIImage.Orientation {
    
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .up:
            return .up
        case .right:
            return .right
        case .down:
            return .down
        case .left:
            return .left
        case .upMirrored:
            return .upMirrored
        case .rightMirrored:
            return .rightMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        default:
            return .up
        }
    }
}
