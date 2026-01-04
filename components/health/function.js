function handler(event) {
    var isIndex = true
    var allowedResources = [
        '.js',
        '.json',
        '.svg',
        '.png',
        '.gif',
        '.css',
        '.ico'
    ];
    var test = ["/ouc-api/", "/oac-api/"]
    var request = event.request;
    var uri = request.uri;
    console.log('uri', uri)
    allowedResources.forEach(resurce => {
        if (uri.includes(resurce)) {
            console.log('R')
            console.log(resurce)
            isIndex = false
        }
    })
    test.forEach((rute) => {
        if (uri.includes(rute)) {
            isIndex = false
        }
    })
    if (isIndex) {
        request.uri = '/index.html'
    }
    
    
    return request;
}