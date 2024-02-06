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
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-01-59.623Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-21-05.779Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-21-17.075Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-22-09.053Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-42-10.367Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-42-23.608Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-43-31.082Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-43-57.333Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-44-23.811Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T13-44-45.925Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T15-43-23.244Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T15-43-42.173Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-12T15-44-01.161Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T10-32-14.521Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T10-32-34.682Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T10-56-50.112Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T11-45-28.815Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T11-45-43.625Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T11-45-56.137Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T12-01-06.368Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T12-03-09.630Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T12-46-44.383Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T12-47-01.136Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T12-53-03.271Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T12-53-24.078Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T12-55-57.515Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T12-57-08.414Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T13-08-44.461Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T13-09-05.983Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T13-10-23.082Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T13-10-50.317Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T14-15-07.007Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T14-40-18.042Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-13T14-40-50.097Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-16T09-21-27.580Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-16T09-25-22.200Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-16T09-27-32.082Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-16T09-28-24.587Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-16T09-30-33.128Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-16T09-38-33.006Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-27-34.940Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-36-51.003Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-37-11.152Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-37-42.771Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-40-42.853Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-40-57.932Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-41-13.792Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-41-27.115Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-42-24.379Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T07-44-13.304Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T18-22-12.645Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-17T18-23-28.954Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-39-10.457Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-39-10.457Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-39-25.499Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-39-25.499Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-39-43.090Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-39-43.090Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-40-01.462Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-40-01.462Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-43-54.289Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-44-11.977Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-44-11.977Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-44-24.558Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T07-44-24.558Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T08-21-21.680Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T08-21-38.757Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T08-21-38.757Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T08-21-52.436Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T08-21-52.436Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T09-11-12.636Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T09-11-36.235Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T09-11-36.235Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T09-13-21.246Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T09-13-35.857Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T09-13-55.493Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T09-13-55.493Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T09-52-41.156Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T10-01-32.196Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T10-01-32.196Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T10-01-48.432Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T10-01-48.432Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T10-13-34.180Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T10-18-50.925Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T10-46-01.659Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T12-51-48.575Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-04-23.710Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-17-23.082Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-41-12.545Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-55-05.730Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-55-38.430Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-55-52.800Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-56-06.961Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-56-06.961Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-57-00.498Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-57-21.598Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-57-40.445Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-57-56.990Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-57-56.990Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-58-11.711Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-58-41.907Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-58-41.907Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-58-55.593Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-58-55.593Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-59-09.130Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-59-09.130Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-59-37.264Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-59-37.264Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-59-52.089Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T13-59-52.089Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-02-11.344Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-02-11.344Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-02-30.490Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-02-30.490Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-02-46.984Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-02-46.984Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-03-01.858Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-03-01.858Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-03-19.151Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-03-19.151Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-03-36.530Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-03-48.845Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-04-13.273Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-04-13.273Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-04-26.690Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-04-26.690Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-04-44.711Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-04-44.711Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-06-25.238Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-06-25.238Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-06-38.514Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-06-38.514Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-06-56.815Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-06-56.815Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-08-09.171Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T14-08-09.171Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-18T15-02-20.124Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-37-29.415Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-37-54.981Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-38-42.903Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-38-42.903Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-39-00.219Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-39-00.219Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-39-45.224Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-39-45.224Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-50-29.992Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-50-29.992Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-53-01.099Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-53-15.818Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-53-15.818Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-53-38.431Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T07-53-38.431Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T12-03-19.529Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T12-03-36.497Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T12-03-36.497Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T12-39-20.336Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T12-39-39.875Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T12-39-58.478Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T12-40-37.253Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-19T12-40-37.253Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T08-07-27.910Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T08-07-37.640Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T08-07-49.104Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T08-07-49.104Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T08-15-41.504Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T08-15-41.504Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T09-20-52.527Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T09-32-12.938Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T09-32-12.938Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T09-33-23.059Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T09-33-23.059Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T09-36-32.333Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T09-36-32.333Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T10-48-51.213Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T10-48-51.213Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T10-49-06.840Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T10-49-06.840Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T10-49-20.698Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T10-49-20.698Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T10-49-35.229Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T10-49-35.229Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-34-44.770Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-34-58.018Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-39-42.823Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-39-42.823Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-39-58.636Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-40-59.370Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-40-59.370Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-41-25.831Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-41-25.831Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-50-42.007Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-50-42.007Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-52-50.783Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-53-08.834Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-10-20T14-53-29.725Z.zip-1.jpg",
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
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-03-20.993Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-45-41.252Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-45-53.528Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T13-46-03.792Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T15-45-09.714Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-12T15-45-40.404Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-33-03.822Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-33-20.865Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-33-40.923Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-39-14.817Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-39-51.199Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-40-04.075Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-40-15.961Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-40-34.400Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-40-46.983Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-41-06.132Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-41-20.774Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T10-57-22.971Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-01-44.853Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-01-58.781Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-02-13.821Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-02-26.352Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-02-44.263Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-02-57.862Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-49-20.146Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-49-30.288Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-50-24.280Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-50-42.106Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-50-55.239Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-52-18.129Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-52-57.009Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-55-58.140Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-56-11.048Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-57-57.553Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-58-07.568Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-58-16.855Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-58-31.406Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-58-32.239Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-58-43.002Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-58-43.819Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-58-59.414Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T12-59-10.638Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-11-19.687Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-11-29.240Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-12-13.799Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-12-28.881Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-12-45.477Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-13-38.470Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-13-52.432Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-14-02.755Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-14-26.827Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-14-41.724Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-14-51.044Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-16-05.439Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-16-15.400Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-16-27.918Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-16-38.436Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-16-59.028Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-17-11.719Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-17-44.545Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-17-58.449Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-18-10.362Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T13-18-22.510Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-14-24.662Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-14-53.774Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-41-17.028Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-41-28.718Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-41-40.282Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-41-51.532Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-42-36.195Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-42-48.555Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-42-59.937Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-43-39.954Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-43-51.853Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-44-15.022Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-44-25.772Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-44-37.012Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-44-47.819Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T14-44-58.224Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-04-56.115Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-05-08.399Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-05-17.599Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-05-27.256Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-05-37.266Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-06-03.820Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-06-13.892Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-06-33.939Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-06-43.618Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-06-54.427Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-07-04.189Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-07-14.434Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-07-23.473Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-07-32.722Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-07-42.565Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-07-52.888Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-08-03.437Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-08-16.369Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-08-27.778Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-08-36.852Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-08-46.445Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-08-56.171Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-09-05.885Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-09-43.118Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-09-52.673Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-11-07.177Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-11-16.977Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-11-26.130Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-11-38.491Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-11-47.776Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-12-04.878Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-12-14.261Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-12-24.335Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-12-34.210Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-13-29.350Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-13-38.517Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T15-13-47.746Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-12-04.446Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-12-17.040Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-12-40.050Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-12-51.875Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-13-01.788Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-13-15.880Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-13-27.517Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-13-44.320Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-13-55.065Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-14-12.739Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-14-22.609Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-14-33.192Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-14-56.259Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-15-17.256Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-15-25.899Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-13T18-15-59.210Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-22-22.165Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-22-38.354Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-26-26.594Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-26-45.456Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-27-05.787Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-27-20.836Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-27-46.223Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-27-58.187Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-28-13.540Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-28-38.526Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-35-32.832Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-35-53.576Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-36-11.610Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-36-24.588Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-16T09-36-37.015Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-17T07-35-34.723Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-17T07-38-30.182Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-17T07-38-48.040Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-17T07-39-16.433Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-17T07-39-37.708Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-18T13-11-10.962Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-18T14-19-41.932Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-18T14-20-07.444Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-18T14-20-27.176Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T09-22-51.743Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T09-23-07.255Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T09-24-25.513Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T09-25-27.413Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T09-25-27.413Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T09-44-19.259Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T09-44-37.964Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T09-44-56.304Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T09-44-56.304Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-10-20T14-54-17.191Z.zip-1.jpg",
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
            let roi = try FaceDetection.detectFacesInImage(image).first?.bounds
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
                let roi = try FaceDetection.detectFacesInImage(image).first?.bounds
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
    
    func failRatioOfDetectionOnEachImage(_ detector: SpoofDetector, detectFace: Bool) throws -> Float {
        var detectionCount: Float = 0
        var failCount: Float = 0
        try withEachImage(types: [.spoofDevice]) { (image, url, positive) in
            let roi = try FaceDetection.detectFacesInImage(image).first?.bounds
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
            let roi = try FaceDetection.detectFacesInImage(image).first?.bounds
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

extension String: LocalizedError {
    
    var localizedDescription: String {
        self
    }
}
