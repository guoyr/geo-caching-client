geo-caching-client
==================

iOS client for the geo-caching project 

[Hard] Cloud Geo-Caching: build a storage service to manage data on at least two geographical locations (e.g. different Amazon AWS availability zones) and a local client. The local client can be either a smart phone or a desktop application. The storage service should transparently move the data between the different locations (and perhaps do prefetching for reads) in order to minimize client-perceived latency. The three locations (2 cloud and 1 local) should not be full mirrors of one another. Instead, one of them should be a master and the other 2 should act as caches to improve performance. The master can be changed to a different location if the client relocates (and you need to be able to show that). The space at each of the cache locations is limited.

For example, assume the client application is a photo viewer+editor. The end-user might add new photos to his album on the local client, and the data will transparently move to the master. If the client views a picture from one album, the storage layer can perhaps pre-fetch all the pictures of that album in order to minimize the latency for future views.

The use of caching in your project should minimize cost and improve performance over a non-cached system.
