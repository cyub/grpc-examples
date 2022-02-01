/*
 *
 * Copyright 2015 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

// Package main implements a client for Greeter service.
package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	pb "github.com/cyub/grpc-lb-example/helloworld/proto"
	"google.golang.org/grpc"
)

const (
	defaultName = "world"
)

func main() {
	flag.Parse()
	domain, exists := os.LookupEnv("SERVER_DOMAIN")
	if !exists {
		domain = "localhost"
	}

	var dnsResolver bool
	if strings.HasPrefix(domain, "dns://") {
		dnsResolver = true
	}

	port, exists := os.LookupEnv("SERVER_PORT")
	if !exists {
		port = "50051"
	}
	// Set up a connection to the server.
	target := fmt.Sprintf("%s:%s", domain, port)
	fmt.Println("conn target:", fmt.Sprintf("%s:%s", domain, port))
	options := []grpc.DialOption{
		grpc.WithInsecure(),
		grpc.WithBlock(),
	}

	if dnsResolver {
		options = append(options, grpc.WithDefaultServiceConfig(`{"loadBalancingPolicy":"round_robin"}`))
	}
	conn, err := grpc.Dial(target, options...)
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()
	c := pb.NewGreeterClient(conn)

	for {
		// Contact the server and print out its response.
		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		defer cancel()
		r, err := c.SayHello(ctx, &pb.HelloRequest{Name: defaultName})
		if err != nil {
			log.Fatalf("could not greet: %v", err)
		}
		log.Printf("Greeting: %s", r.GetMessage())
		time.Sleep(time.Second)
	}

}
