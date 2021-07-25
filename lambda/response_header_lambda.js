'use strict';

const http = require('https');

const indexPage = 'index.html';

exports.handler = async (event, context, callback) => {
    
    const cf = event.Records[0].cf;
    const request = cf.request;
    const response = cf.response;
    const statusCode = response.status;
    const headers = {};

    headers['strict-transport-security'] = [{key: 'Strict-Transport-Security', value: 'max-age=16070400; includeSubdomains; preload'}]; 
    headers['x-content-type-options'] = [{key: 'X-Content-Type-Options', value: 'nosniff'}]; 
    headers['x-frame-options'] = [{key: 'X-Frame-Options', value: 'SAMEORIGIN'}]; 
    headers['x-xss-protection'] = [{key: 'X-XSS-Protection', value: '1; mode=block'}]; 
    headers['referrer-policy'] = [{key: 'Referrer-Policy', value: 'same-origin'}]; 
    headers['x-permitted-cross-domain-policies'] = [{key: 'X-Permitted-Cross-Domain-Policies', value:'none'}];
    //headers['feature-policy'] = [{key: 'Feature-Policy', value: "vibrate 'none'; geolocation 'none'"}];
    headers['expect-ct'] = [{key: 'Expect-CT', value: 'max-age=86400, enforce,'}];
    //headers['public-key-pins'] = [{key: 'Public-Key-Pins', value: 'pin-sha256="klNLH1lUZUINOeCmawYGvIZFz/9haIcWM2L/qDmLA28="; max-age=10000; includeSubDomains'}];
    headers['content-security-policy'] = [{key: 'Content-Security-Policy', value: "default-src * data: blob: 'unsafe-inline' 'unsafe-eval'; img-src * data: blob: 'unsafe-inline'; media-src * data: blob: 'unsafe-inline'; connect-src * data: blob: 'unsafe-inline'; script-src * 'unsafe-inline'; style-src * 'unsafe-inline'; object-src *; font-src * 'unsafe-inline';  frame-src * data: blob: 'unsafe-inline';"}];  
    headers['permissions-policy'] = [{key:'Permissions-Policy', value: "vibrate 'none'; geolocation 'none'"}];

    // Only replace 403 and 404 requests typically received
    // when loading a page for a SPA that uses client-side routing 
    // lalalala
    const doReplace = request.method === 'GET'
                    && (statusCode == '403' || statusCode == '404');

    const result = doReplace 
        ? await generateResponseAndLog(cf, request, indexPage)
        : response;

    response.status = result.status;
    response.headers = {...response.headers, ...result.headers, ...headers};
    response.body = result.body;
    callback(null, response);
        
};

async function generateResponseAndLog(cf, request, indexPage){

    const domain = cf.config.distributionDomainName;
    const appPath = getAppPath(request.uri);
    const indexPath = `/${appPath}/${indexPage}`;

    const response = await generateResponse(domain, indexPath);

    console.log('response: ' + JSON.stringify(response));

    return response;
}

async function generateResponse(domain, path){
    try {
        // Load HTML index from the CloudFront cache
        const s3Response = await httpGet({ hostname: domain, path: path });

        const headers = s3Response.headers || 
            {
                'content-type': [{ value: 'text/html;charset=UTF-8' }],
            };
        return {
            status: '200',
            headers: wrapAndFilterHeaders(headers),
            body: s3Response.body
        };
    } catch (error) {
        return {
            status: '500',
            headers:{
                'content-type': [{ value: 'text/plain' }]
            },
            body: 'An error occurred loading the page'
        };
    }
}

function httpGet(params) {
    return new Promise((resolve, reject) => {
        http.get(params, (resp) => {
            console.log(`Fetching ${params.hostname}${params.path}, status code : ${resp.statusCode}`);
            let result = {
                headers: resp.headers,
                body: ''
            };
            resp.on('data', (chunk) => { result.body += chunk; });
            resp.on('end', () => { resolve(result); });
        }).on('error', (err) => {
            console.log(`Couldn't fetch ${params.hostname}${params.path} : ${err.message}`);
            reject(err, null);
        });
    });
}

// Get the app path segment e.g. candidates.app, employers.client etc
function getAppPath(path){
    if(!path){
        return '';
    }

    if(path[0] === '/'){
        path = path.slice(1);
    }

    const segments = path.split('/');

    // will always have at least one segment (may be empty)
    return segments[0];
}

// Cloudfront requires header values to be wrapped in an array
function wrapAndFilterHeaders(headers){
    const allowedHeaders = [
        "content-type",
        "content-length",
        "date",
        "last-modified",
        "etag",
        "cache-control",
        "accept-ranges",
        "server",
        "age",
        "transfer-encoding"
    ];

    const responseHeaders = {};

    if(!headers){
        return responseHeaders;
    }

    for(var propName in headers) {
        // only include allowed headers
        if(allowedHeaders.includes(propName.toLowerCase())){
            var header = headers[propName];

            if (Array.isArray(header)){
                // assume already 'wrapped' format
                responseHeaders[propName] = header;
            } else {
                // fix to required format
                responseHeaders[propName] = [{ value: header }];
            }    
        }

    }
    console.log('responseHeaders: ' + JSON.stringify(responseHeaders));
    return responseHeaders;
}